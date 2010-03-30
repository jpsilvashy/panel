require 'rubygems'
require 'ruby_to_ansi_c'

# HACK: you should require your dependencies
$array_index_helpers ||= ('a'..'zzz').to_a

class Environment # HACK until ruby_parser is re-released
  alias :old_all :all
  def all
    idx = @dyn.index(false) || 0
    @env[0..idx].reverse.inject { |env, scope| env.merge scope }
  end
end

class RADProcessor < RubyToAnsiC

  @translator = nil

  # REFACTOR: rename to self.process
  def self.translate file, klass, method
    sexp = RubyParser.new.process File.read(file), file
    sexp = s(:block, sexp) unless sexp.sexp_type == :block

    # this sucks... but it finds the class and method within the tree
    # it doesn't currently deal with class methods or anything special
    # AT ALL.

    k_sexp = sexp.find_nodes(:class).find { |k|
      k[1] == klass
    }

    body = k_sexp.scope
    body = body.block if body.block # RubyParser bug?

    m = body.find_nodes(:defn).find { |m|
      m[1] == method
    } rescue nil

    @translator = nil # HACK

    self.translator.process m if m
  end

  def self.translator
    unless @translator then
      @translator = CompositeSexpProcessor.new
      @translator << RADRewriter.new
      @translator << RADTypeChecker.new
      # HACK: more harm than good @translator << CRewriter.new
      @translator << self.new

      @translator.on_error_in(:defn) do |processor, exp, err|
        result = processor.expected.new
        case result
        when Array then
          result << :error
        end
        msg = "// ERROR: #{err.class}: #{err}"
        msg += " in #{exp.inspect}" unless exp.nil? or $TESTING
        msg += " from #{caller.join(', ')}" unless $TESTING
        result << msg
        result
      end

    end
    @translator
  end
  
  def process_iasgn(exp)
    name = exp.shift
    val = process exp.shift
    "__#{name.to_s.sub(/^@/, '')} = #{val}"
  end
  
  def process_ivar(exp)
    name = exp.shift
    "__#{name.to_s.sub(/^@/, '')}"
  end
  
  def process_iter(exp)
    # the array identifer may be in one of two locations
    # when using the instance variable (ivar) style it is located at exp[0][1][1]
    if exp[0][1][1]
      enum = exp[0][1][1]
      enum = "__#{enum.to_s.sub(/^@/, '')}" if enum.to_s =~ /^@/
    # for local variables it is located at exp[0][1][2]  
    elsif exp[0][1][2]
      enum = exp[0][1][2]
    end
    
    out = []
    # Only support enums in C-land # not sure if this comment if valid anymore
    raise UnsupportedNodeError if exp[0][1].nil? # HACK ugly
    @env.scope do
      
      call = process exp.shift
      var  = process(exp.shift).intern # semi-HACK-y 
      body = process exp.shift
      
      # array types from varible_processing>post_process_arrays and arduino_sketch>array
      $array_types.each do |k,v|
            @array_type = v if k == enum.to_s.sub(/^__/,"")
      end
      
      index_helper = $array_index_helpers.shift
      index = "index_#{index_helper}" # solves redeclaration issue

      body += ";" unless body =~ /[;}]\Z/
      body.gsub!(/\n\n+/, "\n")

      out << "unsigned int #{index};" # shouldn't need more than int
      out << "for (#{index} = 0; #{index} < (int) (sizeof(#{enum}) / sizeof(#{enum}[0])); #{index}++) {"   
      out << "#{@array_type} #{var} = #{enum}[#{index}];"
      out << body
      out << "}"
    end

    return out.join("\n")
  end
    
  def process_lasgn(exp)
    out = ""
    var = exp.shift
    value = exp.shift # HACK FUCK || s(:array) # HACK?
    args = value

    exp_type = exp.sexp_type
    @env.add var.to_sym, exp_type
    var_type = self.class.c_type exp_type

    if exp_type.list? then
      assert_type args, :array

      raise "array must be of one type" unless args.sexp_type == Type.homo

      # HACK: until we figure out properly what to do w/ zarray
      # before we know what its type is, we will default to long.
      array_type = args.sexp_types.empty? ? 'void *' : self.class.c_type(args.sexp_types.first)
      # we can fix array here..
      args.shift # :arglist
      out << "#{var} = (#{array_type}) malloc(sizeof(#{array_type}) * #{args.length});\n"
      args.each_with_index do |o,i|
        out << "#{var}[#{i}] = #{process o};\n"
      end
    else
      out << "#{var}"
      out << " = #{process args}" if args
    end

    out.sub!(/;\n\Z/, '')

    return out
  end
  
  def process_str(exp)
    s = exp.shift.gsub(/\n/, '\\n')
    if s.size == 1
      return "\'#{s}\'"
    else
      return "\"#{s}\""
    end
  end


end

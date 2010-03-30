class Panel

  # NOTES:
  #   When app initilizes, it should check all the existing LED's in the DB
  #   It should attempt to update them upon successful connection via serial
  #   Important! App should make sure it doesn't terminate the connection to the device
  #   App may need to send out a heartbeat every 30 seconds (guess) to keep connection alive
  #   After update of LED run something like Panel.new.write(4, 22, 'ff0000')

  # TODO:
  #   remove "initialize" method's SerialPort stuff and incorporate into initializers for the app
  #   "watch" method seems to not be important.

  require 'serialport'
  
  def initialize()
    puts "Starting serial gateway"
    begin
      @sp = SerialPort.new "/dev/tty.usbserial-A6004cNN", 115200, 8, 1, SerialPort::NONE
      self.fps = 12
      at_exit { puts "[Closing connection to panels]" }
    rescue => e
      puts "Cannot initialize panels, connection to master panel failed."
    end
  end
  
  def fps
    @fps
  end
  
  def fps=(fps)
    @fps = fps
    @rate = nil
  end
  
  def rate
    @rate ||= 1000000 / self.fps
  end
  
  def new_frame?
    now = Time.now.usec
    diff = now - @then.to_i
    if diff < 0 || diff > self.rate
      @then = now
      true
    end
  end
  
  def watch
    pid = Process.fork do
      Process.fork do
        sleep 10
        while true do
          sleep 1
          # sp.putc "y"
          @sp.write('heartbeat')
          puts "sent, connected at: #{@sp.write('heartbeat')}"
        end
      end
      exit
    end
    Process.waitpid(pid)
  end

  def setup_address(address)
    return (("%02x" % address.to_s).scan(/../).map { |match| match.hex }).pack('C*')
  end

  def setup_command(command)
    return (command.to_s.scan(/../).map { |match| match.hex }).pack('C*')
  end

  def arrange_serial(address, length, command)
    return ["\x01", address, "\x04", "\x00", "c", command ]
  end

  def write(address, length, command)

    @address = self.setup_address(address)
    @command = self.setup_command(command)

    cmd = self.arrange_serial(@address, length, @command)

    if command.length != 6
      raise "Send length does not match command length"
    end

    @sp.write cmd
  end
  
  def play
    @run = true
  end
  
  def pause
    @run = false
  end
  
  # keyframes in format [["pixel1color","pixel2color"],["pixel1color","pixel2color"]]
  #
  def animate(keyframes)
    i = 0
    self.play
    while @run
      if self.new_frame?
        ## TODO : translate keyframe into real mapping
        # self.write keyframes[i]
        i = (i == keyframes.length-1) ? 0 : i + 1
      end
    end
  end

  def blink
    framerate = 0.5
    while true do
      sleep framerate
      @sp.write ["\x01\x00\x04\x00n\xff\xff\xff"]
      sleep framerate
      @sp.write ["\x01\x00\x04\x00n\xff\xff\xff"]
    end
  end

  def frame_test
    frame_1 = [
      [1,  "ff0000"],  [2,  "00ffff"],  [3,  "0000ff"],  [4,  "00ff00"],  [5,  "ffff00"], 
      [6,  "ff0000"],  [7,  "00ffff"],  [8,  "0000ff"],  [9,  "00ff00"],  [10, "ffff00"], 
      [11, "ff0000"],  [12, "00ffff"],  [13, "0000ff"],  [14, "00ff00"],  [15, "ffff00"], 
      [16, "ff0000"],  [17, "00ffff"],  [18, "0000ff"],  [19, "00ff00"],  [20, "ffff00"], 
      [21, "ff0000"],  [22, "00ffff"],  [23, "0000ff"],  [24, "00ff00"],  [25, "ffff00"]
    ]

    frame_2 = [
      [1,  "ffff00"],  [2,  "ffffff"],  [3,  "0000ff"],  [4,  "00ff00"],  [5,  "ffff00"], 
      [6,  "ff0000"],  [7,  "00ffff"],  [8,  "0000ff"],  [9,  "00ff00"],  [10, "ffff00"], 
      [11, "ff0000"],  [12, "00ffff"],  [13, "0000ff"],  [14, "00ff00"],  [15, "ffff00"], 
      [16, "ff0000"],  [17, "00ffff"],  [18, "0000ff"],  [19, "00ff00"],  [20, "ffff00"], 
      [21, "ff0000"],  [22, "00ffff"],  [23, "0000ff"],  [24, "00ff00"],  [25, "ffffff"]
    ]

    # >> animate = frame_1 - frame_2
    # => [[1, "ff0000"], [2, "00ffff"], [25, "ffff00"]]
    # animate.each {|f| print f[0], (f[1].to_s.scan(/../).map { |match| match.hex }).pack('C*') }

  end

end
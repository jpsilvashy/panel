class Panel

  # NOTES:
  #   When app initilizes, it should check all the existing LED's in the DB
  #   It should attempt to update them upon successful connection via serial
  #   Important! App should make sure it doesn't terminate the connection to the device
  #   App may need to send out a heartbeat every 30 seconds (guess) to keep connection alive
  #   After update of LED run something like Panel.new.send(22, 4, 'ff0000')

  # TODO:
  #   remove "initialize" method's SerialPort stuff and incorporate into initializers for the app
  #   "watch" method seems to not be important.

  require 'serialport'

  def initialize()
    puts "Starting serial gateway"
    begin
      @sp = SerialPort.new "/dev/tty.usbserial-A6004cNN", 115200, 8, 1, SerialPort::NONE
      at_exit { puts "[Closing connection to panels]" }
    rescue => e
      puts "Cannot initialize panels, connection to master panel failed."
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

  def send(length, address, command)

    @address = self.setup_address(address)
    @command = self.setup_command(command)

    cmd = self.arrange_serial(@address, length, @command)

    if command.length != 6
      raise "Send length does not match command length"
    end

    @sp.write cmd
  end

  def test_arr
    
    framerate = 1.0 / 24.0
    
    while true do
      sleep framerate
      @sp.write ["\x01", "\x00", "\x04", "\x00", 'n', "\xff", "\xff", "\xff"]
      sleep framerate
      @sp.write ["\x01", "\x00", "\x04", "\x00", 'n', "\x00", "\x00", "\x00"]
    end
  end

end
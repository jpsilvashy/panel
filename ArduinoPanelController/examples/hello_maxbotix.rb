class HelloMaxbotix < ArduinoSketch
  
  # demonstrate maxbotix ultrasonic range finder
  # http://www.sparkfun.com/commerce/product_info.php?products_id=8502
  # 
  # what it does:
  # the closer an object comes to the maxbotix sensor, the faster the led blinks

  # change your pins to suit your setup
  
  serial_begin :rate => 19200
  
  output_pin 5, :as => :led
  @max_botix_pin = 0      
      
  def loop
    led.on
    delay(ping(@max_botix_pin)*4) 
    led.off
    delay(ping(@max_botix_pin)*4) 
  end
    
end
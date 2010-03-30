class ParallaxPing < ArduinoPlugin

  # RAD plugins are c methods, directives, external variables and assignments and calls 
  # that may be added to the main setup method
  # function prototypes not needed since we generate them automatically
  
  # directives, external variables and setup assignments and calls can be added rails style (not c style)

  # add to directives
  # plugin_directives "#define EXAMPLE 10"

  # add to external variables
  # external_variables "int foo, bar"

  # add the following to the setup method
  # add_to_setup "foo = 1";, "bar = 1;" "sub_setup();"
  
  # one or more methods may be added and prototypes are
  
  # Methods for the Parallax Ping)) UltraSonic Distance Sensor.
  # 
  # refer to the hello_maxbotix example in /examples/hello_maxbotix.rb

  # Triggers a pulse and returns the delay in microseconds for the echo.
  
  int ping(int pin) {
    return analogRead(pin);
  }

end
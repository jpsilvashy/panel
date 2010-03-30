class Basics < ArduinoPlugin
  

  # RAD plugins are c methods, directives, external variables and assignments and calls 
  # that may be added to the main setup method
  # function prototypes not needed since we generate them automatically
  
  # directives, external variables and setup assignments and calls can be added rails style (not c style)
  # hack from http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1209050315

  # plugin_directives "#undef int", "#include <stdio.h>", "char _str[32];", "#define writeln(...) sprintf(_str, __VA_ARGS__); Serial.println(_str)"
  # add to directives
  #plugin_directives "#define EXAMPLE 10"

  # add to external variables
  # ok, we need to deal with 
  # what about variables 
  # need to loose the colon...
  # external_variables "char status_message[40] = \"very cool\"", "char* msg[40]"

  # add the following to the setup method
  # add_to_setup "foo = 1";, "bar = 1;" "sub_setup();"
  
  # one or more methods may be added and prototypes are generated automatically with rake make:upload
  
  # call pulse(us) to pulse a servo 

  #####################

  ## basics.rb contains a set of simple methods such as on an off, enabling things like
  # button.on or button.off

  ## abstract summary:

  ## regarding analog_on:
  ## On newer Arduino boards (including the Mini and BT) with the ATmega168 chip, this function works on pins 3, 5, 6, 9, 10, and 11. Older USB and serial Arduino boards with an ATmega8 only support analogWrite() on pins 9, 10, and 11.

    # 

  ######################



  void on(int pin)
  {
    digitalWrite( pin, HIGH );
  }


  void analog_on(int pin, int val)
  {
    analogWrite( pin, val );
  }


  void off(int pin)
  {
  	digitalWrite( pin, LOW );
  }




end
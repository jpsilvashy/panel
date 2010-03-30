class FrequencyGenerator < ArduinoSketch
  # IMPORTANT -- This is one for four examples that fails with Ruby 1.9 support (latest ruby2c and parsetree)
  # the failing example is commented out and replaced with this hello world until I have a chance to resolve the issue -- jd
  output_pin 13, :as => :led

  def loop
    blink led, 100 
    x = 4
  end
  # need explaination
  
  # output_pin 11, :as => :myTone, :device => :freq_out, :frequency => 100
  # 
  #     def loop
  #         uh_oh 4   
  #     end
  # 
  #     def uh_oh(n)
  #       
  # 
  #         n.times do
  #             myTone.enable
  #             myTone.set_frequency 1800
  #             delay 500
  #             myTone.disable
  #             delay 100
  #             myTone.enable
  #             myTone.set_frequency 1800
  #             delay 800
  #             myTone.enable
  #         end
  #         # hack to help translator guess that n is an int
  #         f = n + 0
  #      end
      

end

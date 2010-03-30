class FirstSound < ArduinoSketch

  # IMPORTANT -- This is one for four examples that fails with Ruby 1.9 support (latest ruby2c and parsetree)
  # the failing example is commented out and replaced with this hello world until I have a chance to resolve the issue -- jd
  output_pin 13, :as => :led

  def loop
    blink led, 100 
    x = 4
  end

# output_pin 11, :as => :myTone, :device => :freq_out, :frequency => 100 # frequency required
# 
#     def loop
#         myTone.disable
#         1.upto(400) { |x| tone_out x }   # run up the scale to 4000 Hz in 10 Hz steps
#         399.downto(1) { |x| tone_out x } # come back down in 10 Hz steps
#         delay 2000
#     end
# 
#     def tone_out(n)
#         myTone.set_frequency 10*n
#         myTone.enable
#         delay 80
#         myTone.disable
#         delay 10
#     end
    

end
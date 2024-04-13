# frozen_string_literal: true

require 'rmagick'

# Demonstrate the Image#color_reset! method

f = Magick::Image.new(100, 100) { |info| info.background_color = 'white' }
red = Magick::Pixel.from_color('red')
f.color_reset!(red)
# f.display
f.write('color_reset.gif')
exit

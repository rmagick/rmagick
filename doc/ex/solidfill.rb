# frozen_string_literal: true

require 'rmagick'

# Demonstrate the SolidFill class

fill = Magick::SolidFill.new('orange')
img = Magick::Image.new(300, 100, fill)

# Annotate the filled image with the code that created the fill.

ann = Magick::Draw.new
ann.annotate(img, 0, 0, 0, 0, "SolidFill.new('orange')") do |options|
  options.gravity = Magick::CenterGravity
  options.fill = 'white'
  options.stroke = 'transparent'
  options.pointsize = 14
end

# img.display
img.write('solidfill.gif')
exit

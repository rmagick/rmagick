#!/usr/bin/env ruby -w
require 'rmagick'

# Demonstrate the GradientFill class

Rows = 100
Cols = 300

Start = '#900'
End = '#000'

fill = Magick::GradientFill.new(0, 0, 0, Rows, Start, End)
img = Magick::Image.new(Cols, Rows, fill)

# Annotate the filled image with the code that created the fill.

ann = Magick::Draw.new
ann.annotate(img, 0, 0, 0, 0, "GradientFill.new(0, 0, 0, #{Rows}, '#{Start}', '#{End}')") do
  self.gravity = Magick::CenterGravity
  self.fill = 'white'
  self.stroke = 'transparent'
  self.pointsize = 14
end

# img.display
img.write('gradientfill.gif')
exit

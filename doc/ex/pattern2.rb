#!/usr/bin/env ruby -w

require 'rmagick'

hat = Magick::Image.read('images/Flower_Hat.jpg').first
hat.resize!(0.25)

# Construct a pattern using the hat image
gc = Magick::Draw.new
gc.pattern('hat', 0, 0, hat.columns, hat.rows) do
  gc.composite(0, 0, 0, 0, hat)
end

# Set the fill to the hat "pattern." Draw an ellipse
gc.fill('hat')
gc.ellipse(150, 75, 140, 70, 0, 360)

# Create a canvas to draw on
img = Magick::Image.new(300, 150, Magick::HatchFill.new('white', 'lightcyan2', 8))

# Draw the ellipse using the fill
gc.draw(img)

img.border!(1, 1, 'lightcyan2')
img.write('pattern2.gif')
exit

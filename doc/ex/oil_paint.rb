#!/usr/bin/env ruby -w
require 'rmagick'

# Demonstrate the Image#oil_paint method

img = Magick::Image.read('images/Flower_Hat.jpg').first

img = img.oil_paint

img.write('oil_paint.jpg')
exit

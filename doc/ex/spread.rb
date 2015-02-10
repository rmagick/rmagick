#!/usr/bin/env ruby -w
require 'rmagick'

# Demonstrate the Image#spread method

img = Magick::Image.read('images/Flower_Hat.jpg').first

img = img.spread

img.write('spread.jpg')
exit

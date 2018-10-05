#!/usr/bin/env ruby -w
require 'rmagick'

# Demonstrate the Image#frame method

img = Magick::Image.read('images/Flower_Hat.jpg').first

img.matte_color = 'gray75'
img = img.frame

img.write('frame.jpg')
exit

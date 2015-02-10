#!/usr/bin/env ruby -w
require 'rmagick'

# Demonstrate the Image#segment method.

img = Magick::Image.read('images/Flower_Hat.jpg').first

img = img.segment(Magick::YUVColorspace, 0.4, 0.4)

img.write('segment.jpg')
exit

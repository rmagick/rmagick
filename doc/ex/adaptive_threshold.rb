#!/usr/bin/env ruby -w
require 'rmagick'

# Demonstrate the Image#adaptive_threshold method

img = Magick::Image.read('images/Flower_Hat.jpg').first
result = img.adaptive_threshold
result.write('adaptive_threshold.jpg')
exit

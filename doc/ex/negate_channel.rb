#!/usr/bin/env ruby -w
require 'rmagick'

# Demonstrate the Image#negate_channel method

img = Magick::Image.read('images/Flower_Hat.jpg').first
result = img.negate_channel(false, Magick::GreenChannel)
result.write('negate_channel.jpg')
exit

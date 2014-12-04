#! /usr/local/bin/ruby -w

require "rmagick"

img = Magick::Image.read('images/Flower_Hat.jpg').first
result = img.posterize
result.write('posterize.jpg')
exit

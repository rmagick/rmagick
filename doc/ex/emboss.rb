#!/usr/bin/env ruby -w
require 'rmagick'

# Demonstrate the Image#edge method

img = Magick::Image.read('images/Flower_Hat.jpg').first

img = img.emboss

img.write('emboss.jpg')
exit

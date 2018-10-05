#!/usr/bin/env ruby -w

require 'rmagick'

img = Magick::Image.read('images/Flower_Hat.jpg').first
sepiatone = img.sepiatone(Magick::QuantumRange * 0.8)
sepiatone.write('sepiatone.jpg')

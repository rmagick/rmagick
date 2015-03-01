#!/usr/bin/env ruby -w
require 'rmagick'

# Demonstrate the Image#add_noise method
NOISE_TYPES = [Magick::UniformNoise, Magick::GaussianNoise,
               Magick::MultiplicativeGaussianNoise,
               Magick::ImpulseNoise, Magick::LaplacianNoise,
               Magick::PoissonNoise]

img = Magick::Image.read('images/Flower_Hat.jpg').first

NOISE_TYPES.each do |noise|
  copy = img.add_noise(noise)
  copy.write "add_noise_#{noise}.jpg"
end
exit

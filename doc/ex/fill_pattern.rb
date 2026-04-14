# frozen_string_literal: true

require 'rmagick'

# Demonstrate the Magick::Draw#fill_pattern and #stroke_pattern attributes.

temp = Magick::ImageList.new
temp << Magick::Image.new(5, 10) { |info| info.background_color = 'black' }
temp << Magick::Image.new(5, 10) { |info| info.background_color = 'gold' }
stroke_pattern = temp.append(false)

img = Magick::Image.new(280, 250) { |info| info.background_color = 'none' }

gc = Magick::Draw.new
gc.annotate(img, 0, 0, 0, 0, "PATT\nERNS") do |options|
  options.gravity = Magick::CenterGravity
  options.font_weight = Magick::BoldWeight
  options.pointsize = 100
  options.fill_pattern = Magick::Image.read('images/Flower_Hat.jpg').first
  options.stroke_width = 5
  options.stroke_pattern = stroke_pattern
end

img.write('fill_pattern.gif')

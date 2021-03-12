require 'rmagick'

# Demonstrate the Magick::Draw#fill_pattern and #stroke_pattern attributes.

temp = Magick::ImageList.new
temp << Magick::Image.new(5, 10) { |e| e.background_color = 'black' }
temp << Magick::Image.new(5, 10) { |e| e.background_color = 'gold' }
stroke_pattern = temp.append(false)

img = Magick::Image.new(280, 250) { |e| e.background_color = 'none' }

gc = Magick::Draw.new
gc.annotate(img, 0, 0, 0, 0, "PATT\nERNS") do |e|
  e.gravity = Magick::CenterGravity
  e.font_weight = Magick::BoldWeight
  e.pointsize = 100
  e.fill_pattern = Magick::Image.read('images/Flower_Hat.jpg').first
  e.stroke_width = 5
  e.stroke_pattern = stroke_pattern
end

img.write('fill_pattern.gif')

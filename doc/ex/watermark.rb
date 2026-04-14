# frozen_string_literal: true

require 'rmagick'

img = Magick::Image.read('images/Flower_Hat.jpg').first

# Make a watermark from the word "RMagick"
mark = Magick::Image.new(140, 40) { |info| info.background_color = 'none' }
gc = Magick::Draw.new

gc.annotate(mark, 0, 0, 0, -5, 'RMagick') do |options|
  options.gravity = Magick::CenterGravity
  options.pointsize = 32
  options.font_family = RUBY_PLATFORM.include?('mingw') ? 'Georgia' : 'Times'
  options.fill = 'white'
  options.stroke = 'none'
end

mark = mark.wave(2.5, 70).rotate(-90)

# Composite the watermark in the lower right (southeast) corner.
img2 = img.watermark(mark, 0.25, 0, Magick::SouthEastGravity)
img2.write('watermark.jpg')

# frozen_string_literal: true

require 'rmagick'

background = Magick::Image.read('images/Flower_Hat.jpg').first
source = Magick::Image.read('pattern:checkerboard') { |options| options.size = "#{background.columns}x#{background.rows}" }.first
mask = Magick::Image.new(background.columns, background.rows) { |info| info.background_color = 'black' }

# Make a mask
gc = Magick::Draw.new
gc.annotate(mask, 0, 0, 0, 0, 'Ruby') do |options|
  options.gravity = Magick::CenterGravity
  options.pointsize = 100
  options.rotation = 90
  options.font_weight = Magick::BoldWeight
  options.fill = 'white'
  options.stroke = 'none'
end

background.add_compose_mask(mask)
result = background.composite(source, Magick::CenterGravity, Magick::OverCompositeOp)
result.write 'compose_mask_example.jpg'
source.write 'compose_mask_source.gif'
mask.write 'compose_mask.gif'

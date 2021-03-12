require 'rmagick'

background = Magick::Image.read('images/Flower_Hat.jpg').first
source = Magick::Image.read('pattern:checkerboard') { |e| e.size = "#{background.columns}x#{background.rows}" }.first
mask = Magick::Image.new(background.columns, background.rows) { |e| e.background_color = 'black' }

# Make a mask
gc = Magick::Draw.new
gc.annotate(mask, 0, 0, 0, 0, 'Ruby') do |e|
  e.gravity = Magick::CenterGravity
  e.pointsize = 100
  e.rotation = 90
  e.font_weight = Magick::BoldWeight
  e.fill = 'white'
  e.stroke = 'none'
end

background.add_compose_mask(mask)
result = background.composite(source, Magick::CenterGravity, Magick::OverCompositeOp)
result.write 'compose_mask_example.jpg'
source.write 'compose_mask_source.gif'
mask.write 'compose_mask.gif'

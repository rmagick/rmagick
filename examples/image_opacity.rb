# Ccreate a semi-transparent title for an image.

require 'rmagick'

puts <<~END_INFO

  This example uses a semi-transparent background color to create a title.
  View the resulting image by entering the command: display image_opacity.miff

END_INFO

balloons = Magick::Image.read('../doc/ex/images/Hot_Air_Balloons_H.jpg').first
legend = Magick::Image.new(160, 50) { |options| options.background_color = '#ffffffc0' }

gc = Magick::Draw.new
gc.annotate(legend, 0, 0, 0, 0, 'Balloon Day!\\nFri May 2 2003') do |options|
  options.gravity = Magick::CenterGravity
  options.stroke = 'transparent'
  options.fill = 'white'
  options.pointsize = 18
end

result = balloons.composite(legend, Magick::SouthGravity, Magick::OverCompositeOp)

puts '...Writing image_opacity.png'
result.write 'image_opacity.png'
exit

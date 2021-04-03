require 'rmagick'

# Demonstrate the Magick::TextureFill class.

granite = Magick::Image.read('granite:').first
fill = Magick::TextureFill.new(granite)
img = Magick::ImageList.new
img.new_image(300, 100, fill)

# Annotate the filled image with the code that created the fill.

ann = Magick::Draw.new
ann.annotate(img, 0, 0, 0, 0, 'TextureFill.new(granite)') do |options|
  options.gravity = Magick::CenterGravity
  options.fill = 'white'
  options.font_weight = Magick::BoldWeight
  options.stroke = 'transparent'
  options.pointsize = 14
end

# img.display
img.write('texturefill.gif')
exit

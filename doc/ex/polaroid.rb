require 'rmagick'
require 'date'

# Demonstrate the Image#polaroid method

img = Magick::Image.read('images/Flower_Hat.jpg').first
img[:Caption] = "\nLosha\n" + Date.today.to_s

begin
  picture = img.polaroid do |e|
    e.font_weight = Magick::NormalWeight
    e.font_style = Magick::NormalStyle
    e.gravity = Magick::CenterGravity
    e.border_color = '#f0f0f8'
  end

  # Composite it on a white background so the result is opaque.
  background = Magick::Image.new(picture.columns, picture.rows)
  result = background.composite(picture, Magick::CenterGravity, Magick::OverCompositeOp)
rescue NotImplementedError
  result = Magick::Image.read('images/notimplemented.gif').first
  result.resize!(img.columns, img.rows)
end

result.write('polaroid.jpg')

# Demonstrate the effects of various composite operators.
# Based on ImageMagick's composite test.

require 'rmagick'

ROWS = 70
COLS = 70
COLOR_A = '#999966'
COLOR_B = '#990066'

img = Magick::Image.new(COLS, ROWS)
triangle = Magick::Draw.new
triangle.fill(COLOR_A)
triangle.stroke('transparent')
triangle.polygon(0, 0, COLS, 0, 0, ROWS, 0, 0)
triangle.draw(img)
image_a = img.transparent('white', alpha: Magick::TransparentAlpha)
image_a['Label'] = 'A'

img = Magick::Image.new(COLS, ROWS)
triangle = Magick::Draw.new
triangle.fill(COLOR_B)
triangle.stroke('transparent')
triangle.polygon(0, 0, COLS, ROWS, COLS, 0, 0, 0)
triangle.draw(img)
image__b = img.transparent('white', alpha: Magick::TransparentAlpha)
image__b['Label'] = 'B'

list = Magick::ImageList.new
null = Magick::Image.read('xc:white') { |options| options.size = Magick::Geometry.new(COLS, ROWS) }
null = null.first.transparent('white', alpha: Magick::TransparentAlpha)
null.border_color = 'transparent'
granite = Magick::Image.read('granite:')

list << null.copy
list << image_a
list << image__b
list << null.copy

list << image__b.composite(image_a, Magick::CenterGravity, Magick::OverCompositeOp)
list.cur_image['Label'] = 'A over B'
list << image_a.composite(image__b, Magick::CenterGravity, Magick::OverCompositeOp)
list.cur_image['Label'] = 'B over A'

list << image__b.composite(image_a, Magick::CenterGravity, Magick::InCompositeOp)
list.cur_image['Label'] = 'A in B'
list << image_a.composite(image__b, Magick::CenterGravity, Magick::InCompositeOp)
list.cur_image['Label'] = 'B in A'

list << image__b.composite(image_a, Magick::CenterGravity, Magick::OutCompositeOp)
list.cur_image['Label'] = 'A out B'
list << image_a.composite(image__b, Magick::CenterGravity, Magick::OutCompositeOp)
list.cur_image['Label'] = 'B out A'

list << image__b.composite(image_a, Magick::CenterGravity, Magick::AtopCompositeOp)
list.cur_image['Label'] = 'A atop B'
list << image_a.composite(image__b, Magick::CenterGravity, Magick::AtopCompositeOp)
list.cur_image['Label'] = 'B atop A'

list << image__b.composite(image_a, Magick::CenterGravity, Magick::XorCompositeOp)
list.cur_image['Label'] = 'A xor B'

list << image__b.composite(image_a, Magick::CenterGravity, Magick::MultiplyCompositeOp)
list.cur_image['Label'] = 'A multiply B'

list << image__b.composite(image_a, Magick::CenterGravity, Magick::ScreenCompositeOp)
list.cur_image['Label'] = 'A screen B'

list << image__b.composite(image_a, Magick::CenterGravity, Magick::DarkenCompositeOp)
list.cur_image['Label'] = 'A darken B'

list << image__b.composite(image_a, Magick::CenterGravity, Magick::LightenCompositeOp)
list.cur_image['Label'] = 'A lighten B'

list << image__b.composite(image_a, Magick::CenterGravity, Magick::PlusCompositeOp)
list.cur_image['Label'] = 'A plus B'

list << image__b.composite(image_a, Magick::CenterGravity, Magick::MinusDstCompositeOp)
list.cur_image['Label'] = 'A minus B'

list << image__b.composite(image_a, Magick::CenterGravity, Magick::ModulusAddCompositeOp)
list.cur_image['Label'] = 'A add B'

list << image__b.composite(image_a, Magick::CenterGravity, Magick::ModulusSubtractCompositeOp)
list.cur_image['Label'] = 'A subtract B'

list << image__b.composite(image_a, Magick::CenterGravity, Magick::DifferenceCompositeOp)
list.cur_image['Label'] = 'A difference B'

list << image__b.composite(image_a, Magick::CenterGravity, Magick::HueCompositeOp)
list.cur_image['Label'] = 'A hue B'

list << image__b.composite(image_a, Magick::CenterGravity, Magick::SaturateCompositeOp)
list.cur_image['Label'] = 'A saturate B'

list << image__b.composite(image_a, Magick::CenterGravity, Magick::LuminizeCompositeOp)
list.cur_image['Label'] = 'A luminize B'

list << image__b.composite(image_a, Magick::CenterGravity, Magick::ColorizeCompositeOp)
list.cur_image['Label'] = 'A colorize B'

list << image__b.composite(image_a, Magick::CenterGravity, Magick::BumpmapCompositeOp)
list.cur_image['Label'] = 'A bumpmap B'

list << image__b.composite(image_a, Magick::CenterGravity, Magick::DissolveCompositeOp)
list.cur_image['Label'] = 'A dissolve B'

list << image__b.composite(image_a, Magick::CenterGravity, Magick::ThresholdCompositeOp)
list.cur_image['Label'] = 'A threshold B'

list << image__b.composite(image_a, Magick::CenterGravity, Magick::ModulateCompositeOp)
list.cur_image['Label'] = 'A modulate B'

list << image_a.composite(image__b, Magick::CenterGravity, Magick::ModulateCompositeOp)
list.cur_image['Label'] = 'B modulate A'

list << image__b.composite(image_a, Magick::CenterGravity, Magick::OverlayCompositeOp)
list.cur_image['Label'] = 'A overlay B'

montage = list.montage do |options|
  options.geometry = Magick::Geometry.new(COLS, ROWS, 3, 3)
  rows = (list.size + 3) / 4
  options.tile = Magick::Geometry.new(4, rows)
  options.texture = granite[0]
  options.fill = 'white'
  options.stroke = 'transparent'
end

montage.write('composite.gif')
exit

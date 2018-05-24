#!/usr/bin/env ruby -w

# Demonstrate the effects of various composite operators.
# Based on ImageMagick's composite test.

require 'rmagick'
include Magick

ROWS = 70
COLS = 70
COLOR_A = '#999966'
COLOR_B = '#990066'

img = Image.new(COLS, ROWS)
triangle = Draw.new
triangle.fill(COLOR_A)
triangle.stroke('transparent')
triangle.polygon(0, 0, COLS, 0, 0, ROWS, 0, 0)
triangle.draw(img)
image_a = img.transparent('white', TransparentOpacity)
image_a['Label'] = 'A'

img = Image.new(COLS, ROWS)
triangle = Draw.new
triangle.fill(COLOR_B)
triangle.stroke('transparent')
triangle.polygon(0, 0, COLS, ROWS, COLS, 0, 0, 0)
triangle.draw(img)
image__b = img.transparent('white', TransparentOpacity)
image__b['Label'] = 'B'

list = ImageList.new
null = Image.read('xc:white') { self.size = Geometry.new(COLS, ROWS) }
null = null.first.transparent('white', TransparentOpacity)
null.border_color = 'transparent'
granite = Image.read('granite:')

list << null.copy
list << image_a
list << image__b
list << null.copy

list << image__b.composite(image_a, CenterGravity, OverCompositeOp)
list.cur_image['Label'] = 'A over B'
list << image_a.composite(image__b, CenterGravity, OverCompositeOp)
list.cur_image['Label'] = 'B over A'

list << image__b.composite(image_a, CenterGravity, InCompositeOp)
list.cur_image['Label'] = 'A in B'
list << image_a.composite(image__b, CenterGravity, InCompositeOp)
list.cur_image['Label'] = 'B in A'

list << image__b.composite(image_a, CenterGravity, OutCompositeOp)
list.cur_image['Label'] = 'A out B'
list << image_a.composite(image__b, CenterGravity, OutCompositeOp)
list.cur_image['Label'] = 'B out A'

list << image__b.composite(image_a, CenterGravity, AtopCompositeOp)
list.cur_image['Label'] = 'A atop B'
list << image_a.composite(image__b, CenterGravity, AtopCompositeOp)
list.cur_image['Label'] = 'B atop A'

list << image__b.composite(image_a, CenterGravity, XorCompositeOp)
list.cur_image['Label'] = 'A xor B'

list << image__b.composite(image_a, CenterGravity, MultiplyCompositeOp)
list.cur_image['Label'] = 'A multiply B'

list << image__b.composite(image_a, CenterGravity, ScreenCompositeOp)
list.cur_image['Label'] = 'A screen B'

list << image__b.composite(image_a, CenterGravity, DarkenCompositeOp)
list.cur_image['Label'] = 'A darken B'

list << image__b.composite(image_a, CenterGravity, LightenCompositeOp)
list.cur_image['Label'] = 'A lighten B'

list << image__b.composite(image_a, CenterGravity, PlusCompositeOp)
list.cur_image['Label'] = 'A plus B'

list << image__b.composite(image_a, CenterGravity, MinusCompositeOp)
list.cur_image['Label'] = 'A minus B'

list << image__b.composite(image_a, CenterGravity, AddCompositeOp)
list.cur_image['Label'] = 'A add B'

list << image__b.composite(image_a, CenterGravity, SubtractCompositeOp)
list.cur_image['Label'] = 'A subtract B'

list << image__b.composite(image_a, CenterGravity, DifferenceCompositeOp)
list.cur_image['Label'] = 'A difference B'

list << image__b.composite(image_a, CenterGravity, HueCompositeOp)
list.cur_image['Label'] = 'A hue B'

list << image__b.composite(image_a, CenterGravity, SaturateCompositeOp)
list.cur_image['Label'] = 'A saturate B'

list << image__b.composite(image_a, CenterGravity, LuminizeCompositeOp)
list.cur_image['Label'] = 'A luminize B'

list << image__b.composite(image_a, CenterGravity, ColorizeCompositeOp)
list.cur_image['Label'] = 'A colorize B'

list << image__b.composite(image_a, CenterGravity, BumpmapCompositeOp)
list.cur_image['Label'] = 'A bumpmap B'

list << image__b.composite(image_a, CenterGravity, DissolveCompositeOp)
list.cur_image['Label'] = 'A dissolve B'

list << image__b.composite(image_a, CenterGravity, ThresholdCompositeOp)
list.cur_image['Label'] = 'A threshold B'

list << image__b.composite(image_a, CenterGravity, ModulateCompositeOp)
list.cur_image['Label'] = 'A modulate B'

list << image_a.composite(image__b, CenterGravity, ModulateCompositeOp)
list.cur_image['Label'] = 'B modulate A'

list << image__b.composite(image_a, CenterGravity, OverlayCompositeOp)
list.cur_image['Label'] = 'A overlay B'

montage = list.montage do
  self.geometry = Geometry.new(COLS, ROWS, 3, 3)
  rows = (list.size + 3) / 4
  self.tile = Geometry.new(4, rows)
  self.texture = granite[0]
  self.fill = 'white'
  self.stroke = 'transparent'
end

montage.write('composite.gif')
exit

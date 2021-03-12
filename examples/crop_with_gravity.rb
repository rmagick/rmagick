#=======================================================#
# Thanks to Robert Wagner for the idea of allowing a    #
# GravityType instead of the x- and y-offset arguments! #
#=======================================================#

# Demo the use of the GravityType argument to Image#crop.

require 'rmagick'
include Magick

shorts = Image.read('../doc/ex/images/Shorts.jpg').first

regwidth = shorts.columns / 2
regheight = shorts.rows / 2

mask = Image.new(regwidth, regheight) { |e| e.background_color = 'white' }
mask.alpha(Magick::ActivateAlphaChannel)
mask.quantum_operator(SetQuantumOperator, 0.50 * QuantumRange, AlphaChannel)

black = Image.new(shorts.columns, shorts.rows) { |e| e.background_color = 'black' }
pairs = ImageList.new

[
  NorthWestGravity, NorthGravity, NorthEastGravity,
  WestGravity, CenterGravity, EastGravity,
  SouthWestGravity, SouthGravity, SouthEastGravity
].each do |gravity|
  pattern = shorts.composite(mask, gravity, OverCompositeOp)
  cropped = shorts.crop(gravity, regwidth, regheight)
  result = black.composite(cropped, gravity, OverCompositeOp)
  result.border_color = 'white'
  pairs << pattern
  pairs << result
end

# Montage into a single image
montage = pairs.montage do |e|
  e.geometry = "#{pairs.columns}x#{pairs.rows}+0+0"
  e.tile = '6x3'
  e.border_width = 1
end
montage.write('crop_with_gravity.png')
# montage.display

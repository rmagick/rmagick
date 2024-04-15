#=======================================================#
# Thanks to Robert Wagner for the idea of allowing a    #
# GravityType instead of the x- and y-offset arguments! #
#=======================================================#

# Demo the use of the GravityType argument to Image#crop.

require 'rmagick'

shorts = Magick::Image.read('images/Shorts.jpg').first

regwidth = shorts.columns / 2
regheight = shorts.rows / 2

mask = Magick::Image.new(regwidth, regheight) { |info| info.background_color = 'white' }
mask.alpha(Magick::ActivateAlphaChannel)
mask.quantum_operator(Magick::SetQuantumOperator, 0.50 * Magick::QuantumRange, Magick::AlphaChannel)

black = Magick::Image.new(shorts.columns, shorts.rows) { |info| info.background_color = 'black' }
pairs = Magick::ImageList.new

[
  Magick::NorthWestGravity, Magick::NorthGravity, Magick::NorthEastGravity,
  Magick::WestGravity, Magick::CenterGravity, Magick::EastGravity,
  Magick::SouthWestGravity, Magick::SouthGravity, Magick::SouthEastGravity
].each do |gravity|
  pattern = shorts.composite(mask, gravity, Magick::OverCompositeOp)
  cropped = shorts.crop(gravity, regwidth, regheight)
  result = black.composite(cropped, gravity, Magick::OverCompositeOp)
  result.border_color = 'white'
  pairs << pattern
  pairs << result
end

# Montage into a single image
montage = pairs.montage do |options|
  options.geometry = "#{pairs.columns}x#{pairs.rows}+0+0"
  options.tile = '6x3'
  options.border_width = 1
end
montage.write('crop_with_gravity.png')
# montage.display

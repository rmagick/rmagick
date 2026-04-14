# frozen_string_literal: true

require 'rmagick'

# Demonstrate the HatchFill class

COLS = 300
ROWS = 100

BACKGROUND = 'white'
FOREGROUND = 'LightCyan2'

fill = Magick::HatchFill.new(BACKGROUND, FOREGROUND)
img = Magick::ImageList.new
img.new_image(COLS, ROWS, fill)

# Annotate the filled image with the code that created the fill.

ann = Magick::Draw.new
ann.annotate(img, 0, 0, 0, 0, "HatchFill.new('#{BACKGROUND}', '#{FOREGROUND}')") do |options|
  options.gravity = Magick::CenterGravity
  options.fill = 'black'
  options.stroke = 'transparent'
  options.pointsize = 14
end
# img.display
img.write('hatchfill.gif')
exit

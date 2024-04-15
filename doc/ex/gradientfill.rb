require 'rmagick'

# Demonstrate the GradientFill class

ROWS = 100
COLS = 300

START_COLOR = '#900'
END_COLOR = '#000'

fill = Magick::GradientFill.new(0, 0, 0, ROWS, START_COLOR, END_COLOR)
img = Magick::Image.new(COLS, ROWS, fill)

# Annotate the filled image with the code that created the fill.

ann = Magick::Draw.new
ann.annotate(img, 0, 0, 0, 0, "GradientFill.new(0, 0, 0, #{ROWS}, '#{START_COLOR}', '#{END_COLOR}')") do |options|
  options.gravity = Magick::CenterGravity
  options.fill = 'white'
  options.stroke = 'transparent'
  options.pointsize = 14
end

# img.display
img.write('gradientfill.gif')
exit

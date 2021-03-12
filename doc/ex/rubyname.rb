require 'rmagick'

# Demonstrate the annotate method

Text = 'RMagick'

granite = Magick::ImageList.new('granite:')
canvas = Magick::ImageList.new
canvas.new_image(300, 100, Magick::TextureFill.new(granite))

text = Magick::Draw.new
text.pointsize = 52
text.gravity = Magick::CenterGravity

text.annotate(canvas, 0, 0, 2, 2, Text) do |e|
  e.fill = 'gray83'
end

text.annotate(canvas, 0, 0, -1.5, -1.5, Text) do |e|
  e.fill = 'gray40'
end

text.annotate(canvas, 0, 0, 0, 0, Text) do |e|
  e.fill = 'darkred'
end

# canvas.display
canvas.write('rubyname.gif')
exit

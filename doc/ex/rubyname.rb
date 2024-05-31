# frozen_string_literal: true

require 'rmagick'

# Demonstrate the annotate method

TEXT = 'RMagick'

granite = Magick::ImageList.new('granite:')
canvas = Magick::ImageList.new
canvas.new_image(300, 100, Magick::TextureFill.new(granite))

text = Magick::Draw.new
text.pointsize = 52
text.gravity = Magick::CenterGravity

text.annotate(canvas, 0, 0, 2, 2, TEXT) do |options|
  options.fill = 'gray83'
end

text.annotate(canvas, 0, 0, -1.5, -1.5, TEXT) do |options|
  options.fill = 'gray40'
end

text.annotate(canvas, 0, 0, 0, 0, TEXT) do |options|
  options.fill = 'darkred'
end

# canvas.display
canvas.write('rubyname.gif')
exit

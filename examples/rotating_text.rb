# Demonstrate the Draw#rotation= method by producing
# an animated MIFF file showing a rotating text string.

require 'rmagick'

puts <<~END_INFO
  Demonstrate the rotation= attribute in the Draw class
  by producing an animated image. View the output image
  by entering the command: animate rotating_text.miff
END_INFO

text = Magick::Draw.new
text.pointsize = 28
text.font_weight = Magick::BoldWeight
text.font_style = Magick::ItalicStyle
text.gravity = Magick::CenterGravity
text.fill = 'white'

# Let's make it interesting. Composite the
# rotated text over a gradient fill background.
fill = Magick::GradientFill.new(100, 100, 100, 100, 'yellow', 'red')
bg = Magick::Image.new(200, 200, fill)

# The "none" color is transparent.
fg = Magick::Image.new(bg.columns, bg.rows) { |options| options.background_color = 'none' }

# Here's where we'll collect the individual frames.
animation = Magick::ImageList.new

0.step(345, 15) do |degrees|
  frame = fg.copy
  text.annotate(frame, 0, 0, 0, 0, 'Rotating Text') do |options|
    options.rotation = degrees
  end
  # Composite the text over the gradient filled background frame.
  animation << bg.composite(frame, Magick::CenterGravity, Magick::DisplaceCompositeOp)
end

animation.delay = 8

# animation.animate
puts '...Writing rotating_text.gif'
animation.write('rotating_text.gif')
exit

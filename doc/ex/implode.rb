#!/usr/bin/env ruby -w

require 'rmagick'

img = Magick::Image.read('images/Flower_Hat.jpg').first

legend = Magick::Draw.new
legend.stroke = 'transparent'
legend.fill = 'white'
legend.gravity = Magick::SouthGravity

frames = Magick::ImageList.new

implosion = 0.25
8.times do
  frames << img.implode(implosion)
  legend.annotate(frames, 0, 0, 10, 20, format('% 4.2f', implosion))
  frames.alpha(Magick::DeactivateAlphaChannel)
  implosion -= 0.10
end

7.times do
  implosion += 0.10
  frames << img.implode(implosion)
  legend.annotate(frames, 0, 0, 10, 20, format('% 4.2f', implosion))
  frames.alpha(Magick::DeactivateAlphaChannel)
end

frames.delay = 10
frames.iterations = 0
puts 'Producing animation...'

frames.write('implode.gif')
exit

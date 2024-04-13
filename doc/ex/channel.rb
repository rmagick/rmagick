# frozen_string_literal: true

require 'rmagick'

img = Magick::Image.read('images/Flower_Hat.jpg').first
imgs = Magick::ImageList.new

imgs << img
imgs << img.channel(Magick::RedChannel)
imgs.cur_image['Label'] = 'RedChannel'
imgs <<  img.channel(Magick::GreenChannel)
imgs.cur_image['Label'] = 'GreenChannel'
imgs << img.channel(Magick::BlueChannel)
imgs.cur_image['Label'] = 'BlueChannel'

result = imgs.montage do |options|
  options.tile = '2x2'
  options.background_color = 'black'
  options.stroke = 'transparent'
  options.fill = 'white'
  options.pointsize = 9
  options.geometry = Magick::Geometry.new(img.columns / 2, img.rows / 2, 5, 5)
end

result.write('channel.jpg')

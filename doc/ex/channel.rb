#!/usr/bin/env ruby -w

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

result = imgs.montage do
  self.tile = '2x2'
  self.background_color = 'black'
  self.stroke = 'transparent'
  self.fill = 'white'
  self.pointsize = 9
  self.geometry = Magick::Geometry.new(img.columns / 2, img.rows / 2, 5, 5)
end

result.write('channel.jpg')

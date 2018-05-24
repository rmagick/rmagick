#!/usr/bin/env ruby -w
require 'rmagick'

# Demonstrate the Image#contrast method

img = Magick::ImageList.new('images/Flower_Hat.jpg')
img.resize!(0.5)

# Prepare to label each image with a number from 1 to 4
legend = Magick::Draw.new
legend.stroke = 'transparent'
legend.pointsize = 12
legend.gravity = Magick::SouthEastGravity

# Add 3 images, each one having slightly less contrast
f = 1
3.times do
  img << img.contrast

  # Annotate the previous image
  legend.annotate(img[f - 1], 0, 0, 7, 10, f.to_s)
  f += 1
end

# Annotate the last image
legend.annotate(img, 0, 0, 7, 10, f.to_s)

# Montage into a single image
imgs = img.montage do
  self.geometry = Magick::Geometry.new(img.columns, img.rows)
  self.tile = '2x2'
end

imgs.write('contrast.jpg')
# imgs.display
exit

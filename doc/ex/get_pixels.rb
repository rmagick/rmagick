#!/usr/bin/env ruby -w
require 'rmagick'

# Demonstrate partial transparency and the get_pixels and
# store_pixels methods by creating an image that goes from
# full-color on the left to monochrome on the right.

# Read the colorful picture of a rock formation. Scale
# it to 300 pixels high because we don't want a big picture.
rocks = Magick::Image.read('images/Red_Rocks.jpg').first
rocks.scale!(250.0 / rocks.rows)

# Make a monochrome copy. See Image#quantize for details
grayrocks = rocks.quantize(256, Magick::GRAYColorspace)

rows = grayrocks.rows
cols = grayrocks.columns

# Create an array of opacity values, proceeding from
# transparent to opaque. The array should have as many
# elements as there are columns in the image. The first
# element should be TransparentOpacity and each succeeding
# element slightly more opaque than its predecessor.
step = Magick::TransparentOpacity / cols.to_f
opacity_steps = Array.new(cols)
cols.times do |x|
  opacity_steps[x] = Magick::TransparentOpacity - Integer(x * step)
  opacity_steps[x] = Magick::OpaqueOpacity if opacity_steps[x] < Magick::OpaqueOpacity
end

# Get each row of pixels from the mono image.
# Copy the pre-computed opacity values to the pixels.
# Store the pixels back.
rows.times do |y|
  pixels = grayrocks.get_pixels(0, y, cols, 1)
  pixels.each_with_index { |p, x| p.opacity = opacity_steps[x] }
  grayrocks.store_pixels(0, y, cols, 1, pixels)
end

# Composite the mono version of the image over the color version.
grayrocks.matte = true
combine = rocks.composite(grayrocks, Magick::CenterGravity, Magick::OverCompositeOp)
# combine.display
combine.write 'get_pixels.jpg'
exit

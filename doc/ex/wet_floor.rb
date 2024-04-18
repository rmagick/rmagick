require 'rmagick'

results = Magick::ImageList.new

img = Magick::Image.new(270, 60) { |info| info.background_color = 'black' }

gc = Magick::Draw.new
gc.annotate(img, 0, 0, 0, -15, 'RUBY!') do |options|
  options.fill = '#a00'
  options.stroke = '#f00'
  options.stroke_width = 2
  options.font_weight = Magick::BoldWeight
  options.gravity = Magick::SouthGravity
  if RUBY_PLATFORM.match?(/mswin32/)
    options.font_family = 'Georgia'
    options.pointsize = 76
  else
    options.font_family = 'times'
    options.pointsize = 80
  end
end

# Add a little bit of shading
shade = img.shade(true, 310, 30)
img.composite!(shade, Magick::CenterGravity, Magick::HardLightCompositeOp)

# Create the default reflection
reflection = img.wet_floor

ilist = Magick::ImageList.new
ilist << img << reflection
results << ilist.append(true)

# Change the initial level of transparency and the rate of transition
ilist[1] = img.wet_floor(0.25, 0.5)
results << ilist.append(true)

# Add a slant
xform = Magick::AffineMatrix.new(1.0, 0.0, Math::PI / 4.0, 1.0, 0.0, 0.0)
ilist[1] = ilist[1].affine_transform(xform)
results << ilist.append(true)

# Add a ripple
ilist[1] = ilist[1].rotate(90).wave(2, 10).rotate(-90)
results << ilist.append(true)

# Montage into a single demo image. Use a white background so
# there won't be any problems with transparency in the browser.
result = results.montage do |options|
  options.geometry = '270x120'
  options.tile = '1x4'
  options.background_color = 'black'
end
result.write('wet_floor.gif')

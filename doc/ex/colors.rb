require 'rmagick'

puts('Creating colors.miff. This may take a few seconds...')

colors = Magick::ImageList.new

# Add a row of "null" colors so we'll have
# room to add the title at the top.
4.times { colors.read('null:') }

puts("\tCreating color swatches...")

# Create a 200x25 image for each named color.
# Label with the name, RGB values, and compliance type.
Magick.colors do |c|
  if c.name !~ /grey/ # omit SVG 'grays'
    colors.new_image(200, 25) do |options|
      options.background_color = c.color
      options.border_color = 'gray50'
    end
    rgb  = sprintf('#%02x%02x%02x', c.color.red & 0xff, c.color.green & 0xff, c.color.blue & 0xff)
    rgb += sprintf('%02x', c.color.alpha & 0xff) if c.color.alpha != Magick::QuantumRange
    m = /(.*?)Compliance/.match c.compliance.to_s
    colors.cur_image['Label'] = "#{c.name} (#{rgb}) #{m[1]}"
  end
end

puts("\tCreating montage...")

# Montage. Each image will have 40 tiles.
# There will be 16 images.
montage = colors.montage do |options|
  options.geometry = '200x25+10+5'
  options.gravity = Magick::CenterGravity
  options.tile = '4x10'
  options.background_color = 'black'
  options.border_width = 1
  options.fill = 'white'
  options.stroke = 'transparent'
end

# Add the title at the top, over the 'null:'
# tiles we added at the very beginning.
title = Magick::Draw.new
title.annotate(montage, 0, 0, 0, 20, 'Named Colors') do |options|
  options.fill = 'white'
  options.stroke = 'transparent'
  options.pointsize = 32
  options.font_weight = Magick::BoldWeight
  options.gravity = Magick::NorthGravity
end

puts("\tWriting ./colors.miff")
montage.each { |f| f.compression = Magick::ZipCompression }
montage.write('colors.miff')

# Make a small sample of the full montage to display in the HTML file.
sample = montage[8].crop(55, 325, 495, 110)
sample.page = Magick::Rectangle.new(495, 110)
sample.write('colors.gif')

exit

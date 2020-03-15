require 'rmagick'

img = Magick::Image.read('images/Flower_Hat.jpg').first
Magick::PreviewType.values.each do |type|
  puts "** Generate #{type}"
  preview = img.preview(type)
  preview.minify.write("preview_#{type}.jpg")
end

require 'rmagick'

img = Magick::Image.read('images/Flower_Hat.jpg').first
preview = img.preview(Magick::SolarizePreview)
preview.minify.write('preview.jpg')
exit

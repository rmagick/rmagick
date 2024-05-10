require 'rmagick'

img = Magick::Image.read('images/Flower_Hat.jpg').first
result = img.posterize(2)
result.write('posterize.jpg')
exit

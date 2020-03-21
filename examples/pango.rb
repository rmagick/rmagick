require 'rmagick'

# In order to run this example,
# ImageMagick should be built with pango library, like following
#
#   brew install pango
#   curl -O https://imagemagick.org/download/ImageMagick-6.9.10-84.tar.xz
#   tar xvJf ImageMagick-6.9.10-84.tar.xz
#   cd ImageMagick-6.9.10-84
#   ./configure --with-pango
#   make install
#
# See https://www.imagemagick.org/Usage/text/#pango

supported_formats = Magick.formats
if supported_formats["PANGO"].to_s != '*r--'
  puts 'ImageMagick is configured without pango supporting.'
  exit 1
end

image = Magick::Image.read('pango:The <b>bold</b> and <i>beautiful</i>').first
image.write('pango_sample1.png')

image = Magick::Image.read('pango:@pango_sample.pango').first
image.write('pango_sample2.png')

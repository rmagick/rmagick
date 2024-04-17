#
# Demonstrate the export_pixels and import_pixels methods.
#

require 'rmagick'

puts <<~END_INFO

  This example demonstrates the export_pixels and import_pixels methods
  by copying an image one row at a time. The result is an copy that
  is identical to the original.

END_INFO

img = Magick::Image.read('../doc/ex/images/Gold_Statue.jpg').first
copy = Magick::Image.new(img.columns, img.rows)

begin
  img.rows.times do |r|
    scanline = img.export_pixels(0, r, img.columns, 1, 'RGB')
    copy.import_pixels(0, r, img.columns, 1, 'RGB', scanline)
  end
rescue NotImplementedError
  warn 'The export_pixels and import_pixels methods are not supported ' \
       'by this version of ImageMagick/GraphicsMagick'
  exit
end

copy.write('copy.gif')
exit

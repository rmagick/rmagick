require 'rmagick'

# Draw a big red Bezier curve on a transparent background.
img = Magick::Image.new(340, 120) { |info| info.background_color = 'none' }
gc = Magick::Draw.new
gc.fill('none')
gc.stroke('red')
gc.stroke_linecap('round')
gc.stroke_width(10)
gc.bezier(20, 60, 20, -90, 320, 210, 320, 60)
gc.draw(img)

img.write('shadow_before.png')

# Create the shadow.
shadow = img.shadow(-5, -5)

image_list = Magick::ImageList.new
image_list.new_image(img.columns, img.rows, Magick::SolidFill.new('white'))
image_list << shadow
image_list << img
image_list.flatten_images.write('shadow_after.png')

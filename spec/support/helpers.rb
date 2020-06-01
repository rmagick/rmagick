module TestHelpers
  TEST_PIXELS = {
    RGB: [[45, 98, 156], [209, 171, 11], [239, 236, 2], [8, 65, 247]],
    CMYK: [[23, 54, 186, 76], [29, 71, 131, 122], [239, 206, 99, 76], [84, 165, 47, 54]]
  }

  def build_image(mode: "RGB", pixels: TEST_PIXELS.fetch(mode.to_sym))
    image = Magick::Image.new(2, 2)
    image.import_pixels(0, 0, 2, 2, mode, pixels.flatten)
  end

  def gray(pixel_value)
    [pixel_value, pixel_value, pixel_value]
  end

  def value_by_version(hash)
    major, minor = Gem::Version.new(Magick::IMAGEMAGICK_VERSION).segments
    hash.fetch(:"#{major}.#{minor}")
  end
end

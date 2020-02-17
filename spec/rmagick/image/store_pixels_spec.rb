require 'tmpdir'

RSpec.describe Magick::Image, '#store_pixels' do
  it 'works' do
    image = described_class.new(20, 20)
    pixels = image.get_pixels(0, 0, image.columns, 1)

    res = image.store_pixels(0, 0, image.columns, 1, pixels)
    expect(res).to be(image)

    pixels[0] = 'x'
    expect { image.store_pixels(0, 0, image.columns, 1, pixels) }.to raise_error(TypeError)
    expect { image.store_pixels(-1, 0, image.columns, 1, pixels) }.to raise_error(RangeError)
    expect { image.store_pixels(0, -1, image.columns, 1, pixels) }.to raise_error(RangeError)
    expect { image.store_pixels(0, 0, 1 + image.columns, 1, pixels) }.to raise_error(RangeError)
    expect { image.store_pixels(-1, 0, 1, 1 + image.rows, pixels) }.to raise_error(RangeError)
    expect { image.store_pixels(0, 0, image.columns, 1, ['x']) }.to raise_error(IndexError)
  end

  it 'supports CMYK color' do
    image = described_class.new(1, 1)
    image.colorspace = Magick::CMYKColorspace

    pixel = Magick::Pixel.new
    pixel.cyan    = 49  * 257
    pixel.magenta = 181 * 257
    pixel.yellow  = 1   * 257
    pixel.black   = 183 * 257

    image.store_pixels(0, 0, 1, 1, [pixel])

    temp_file_path = File.join(Dir.tmpdir, 'rmagick_store_pixel.jpg')
    image.write(temp_file_path)

    image2 = described_class.read(temp_file_path).first
    pixel = image2.get_pixels(0, 0, 1, 1).first

    expect(pixel.cyan).to    equal(49  * 257)
    expect(pixel.magenta).to equal(181 * 257)
    expect(pixel.yellow).to  equal(1   * 257)
    expect(pixel.black).to   equal(183 * 257)

    File.delete(temp_file_path)
  end
end

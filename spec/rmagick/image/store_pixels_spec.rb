require 'tmpdir'

RSpec.describe Magick::Image, '#store_pixels' do
  before do
    @img = described_class.new(20, 20)
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    pixels = @img.get_pixels(0, 0, @img.columns, 1)
    expect do
      res = @img.store_pixels(0, 0, @img.columns, 1, pixels)
      expect(res).to be(@img)
    end.not_to raise_error

    pixels[0] = 'x'
    expect { @img.store_pixels(0, 0, @img.columns, 1, pixels) }.to raise_error(TypeError)
    expect { @img.store_pixels(-1, 0, @img.columns, 1, pixels) }.to raise_error(RangeError)
    expect { @img.store_pixels(0, -1, @img.columns, 1, pixels) }.to raise_error(RangeError)
    expect { @img.store_pixels(0, 0, 1 + @img.columns, 1, pixels) }.to raise_error(RangeError)
    expect { @img.store_pixels(-1, 0, 1, 1 + @img.rows, pixels) }.to raise_error(RangeError)
    expect { @img.store_pixels(0, 0, @img.columns, 1, ['x']) }.to raise_error(IndexError)
  end

  it 'supports CMYK color' do
    img = described_class.new(1, 1)
    img.colorspace = Magick::CMYKColorspace

    pixel = Magick::Pixel.new
    pixel.cyan    = 49  * 257
    pixel.magenta = 181 * 257
    pixel.yellow  = 1   * 257
    pixel.black   = 183 * 257

    img.store_pixels(0, 0, 1, 1, [pixel])

    temp_file_path = File.join(Dir.tmpdir, 'rmagick_store_pixel.jpg')
    img.write(temp_file_path)

    img2 = described_class.read(temp_file_path).first
    pixel = img2.get_pixels(0, 0, 1, 1).first

    expect(pixel.cyan).to    equal(49  * 257)
    expect(pixel.magenta).to equal(181 * 257)
    expect(pixel.yellow).to  equal(1   * 257)
    expect(pixel.black).to   equal(183 * 257)

    File.delete(temp_file_path)
  end
end

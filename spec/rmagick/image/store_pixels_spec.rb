RSpec.describe Magick::Image, '#store_pixels' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
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
end

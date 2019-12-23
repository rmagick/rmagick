RSpec.describe Magick::Image, '#get_pixels' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    expect do
      pixels = @img.get_pixels(0, 0, @img.columns, 1)
      expect(pixels).to be_instance_of(Array)
      expect(pixels.length).to eq(@img.columns)
      expect(pixels.all? { |p| p.is_a? Magick::Pixel }).to be(true)
    end.not_to raise_error
    expect { @img.get_pixels(0,  0, -1, 1) }.to raise_error(RangeError)
    expect { @img.get_pixels(0,  0, @img.columns, -1) }.to raise_error(RangeError)
    expect { @img.get_pixels(0,  0, @img.columns + 1, 1) }.to raise_error(RangeError)
    expect { @img.get_pixels(0,  0, @img.columns, @img.rows + 1) }.to raise_error(RangeError)
  end

  it 'supports CMYK color' do
    img = Magick::Image.read(File.join(FIXTURE_PATH, 'cmyk.jpg')).first
    pixel = img.get_pixels(0, 0, 1, 1).first

    # convert cmyk.jpg -format '%[pixel:p{1,1}]' info:-
    # => cmyk(49,181,1,183)
    expect(pixel.cyan).to    equal(49  * 257)
    expect(pixel.magenta).to equal(181 * 257)
    expect(pixel.yellow).to  equal(1   * 257)
    expect(pixel.black).to   equal(183 * 257)
  end
end

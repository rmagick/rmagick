require 'tmpdir'

RSpec.describe Magick::Image, '#get_pixels' do
  it 'works' do
    img = described_class.new(20, 20)

    expect do
      pixels = img.get_pixels(0, 0, img.columns, 1)
      expect(pixels).to be_instance_of(Array)
      expect(pixels.length).to eq(img.columns)
      expect(pixels.all? { |p| p.is_a? Magick::Pixel }).to be(true)
    end.not_to raise_error
    expect { img.get_pixels(0,  0, -1, 1) }.to raise_error(RangeError)
    expect { img.get_pixels(0,  0, img.columns, -1) }.to raise_error(RangeError)
    expect { img.get_pixels(0,  0, img.columns + 1, 1) }.to raise_error(RangeError)
    expect { img.get_pixels(0,  0, img.columns, img.rows + 1) }.to raise_error(RangeError)
  end

  it 'supports CMYK color' do
    img = described_class.read(File.join(FIXTURE_PATH, 'cmyk.jpg')).first
    pixel = img.get_pixels(0, 0, 1, 1).first

    # convert cmyk.jpg -format '%[pixel:p{1,1}]' info:-
    # => cmyk(49,181,1,183)
    expect(pixel.cyan).to    equal(49  * 257)
    expect(pixel.magenta).to equal(181 * 257)
    expect(pixel.yellow).to  equal(1   * 257)
    expect(pixel.black).to   equal(183 * 257)
  end

  it 'get proper alpha value' do
    img = described_class.new(1, 1)

    pixel = Magick::Pixel.new
    pixel.red   = 12 * 257
    pixel.green = 34 * 257
    pixel.blue  = 56 * 257
    pixel.alpha = 78 * 257

    img.alpha(Magick::SetAlphaChannel)
    img.store_pixels(0, 0, 1, 1, [pixel])

    temp_file_path = File.join(Dir.tmpdir, 'rmagick_get_pixels.png')
    img.write(temp_file_path)

    img2 = described_class.read(temp_file_path).first
    pixel = img2.get_pixels(0, 0, 1, 1).first

    expect(pixel.red).to   equal(12 * 257)
    expect(pixel.green).to equal(34 * 257)
    expect(pixel.blue).to  equal(56 * 257)
    expect(pixel.alpha).to be_within(78 * 257).of(1)
  end
end

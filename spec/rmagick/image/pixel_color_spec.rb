RSpec.describe Magick::Image, '#pixel_color' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.pixel_color(0, 0)
    expect(result).to be_instance_of(Magick::Pixel)

    result = image.pixel_color(0, 0)
    expect(result.to_color).to eq(image.background_color)
    result = image.pixel_color(0, 0, 'red')
    expect(result.to_color).to eq('white')
    result = image.pixel_color(0, 0)
    expect(result.to_color).to eq('red')

    blue = Magick::Pixel.new(0, 0, Magick::QuantumRange)
    expect { image.pixel_color(0, 0, blue) }.not_to raise_error
    # If args are out-of-bounds return the background color
    image = described_class.new(10, 10) { self.background_color = 'blue' }
    expect(image.pixel_color(50, 50).to_color).to eq('blue')

    image.class_type = Magick::PseudoClass
    result = image.pixel_color(0, 0, 'red')
    expect(result.to_color).to eq('blue')
  end

  it 'get/set CYMK color', supported_after('6.8.0') do
    image = described_class.new(20, 30) { self.quality = 100 }
    image.colorspace = Magick::CMYKColorspace

    pixel = Magick::Pixel.new
    pixel.cyan    = 49  * 257
    pixel.magenta = 181 * 257
    pixel.yellow  = 1   * 257
    pixel.black   = 183 * 257

    image.pixel_color(15, 20, pixel)

    temp_file_path = File.join(Dir.tmpdir, 'rmagick_pixel_color.jpg')
    image.write(temp_file_path)

    image2 = described_class.read(temp_file_path).first
    pixel = image2.pixel_color(15, 20)

    expect(pixel.cyan).to    equal(49  * 257)
    expect(pixel.magenta).to equal(181 * 257)
    expect(pixel.yellow).to  equal(1   * 257)
    expect(pixel.black).to   equal(183 * 257)

    File.delete(temp_file_path)
  end
end

RSpec.describe Magick::Image::Info, '#matte_color' do
  it 'works' do
    info = described_class.new

    expect { info.matte_color = 'red' }.not_to raise_error
    red = Magick::Pixel.new(Magick::QuantumRange)
    expect { info.matte_color = red }.not_to raise_error
    expected = value_by_version(
      "6.8": "#FFFF00000000",
      "6.9": "#FFFF00000000FFFF",
      "7.0": "#FFFF00000000FFFF",
      "7.1": "#FFFF00000000FFFF"
    )
    expect(info.matte_color).to eq(expected)
    image = Magick::Image.new(20, 20) { |options| options.matte_color = 'red' }
    expect(image.matte_color).to eq(expected)
    expect { info.matte_color = nil }.to raise_error(TypeError)
  end
end

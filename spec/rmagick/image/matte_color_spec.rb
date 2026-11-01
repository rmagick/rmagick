# frozen_string_literal: true

RSpec.describe Magick::Image, '#matte_color' do
  it 'returns the name in sRGB for a CMYK image' do
    image = described_class.new(1, 1) { |info| info.depth = 16 }
    image.colorspace = Magick::CMYKColorspace

    expect(image.matte_color).to eq('#BDBDBDBDBDBDFFFF')
    image.matte_color = 'red'
    expect(image.matte_color).to eq('#FFFF00000000FFFF')
    name = image.matte_color
    image.matte_color = name
    expect(image.matte_color).to eq('#FFFF00000000FFFF')
  end

  it 'returns a CMYK color name in sRGB' do
    image = described_class.new(1, 1) { |info| info.depth = 16 }
    image.matte_color = 'cmyk(100%,0,0,0)'

    expect(image.matte_color).to eq('#0000FFFFFFFFFFFF')
  end
end

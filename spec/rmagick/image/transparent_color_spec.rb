# frozen_string_literal: true

RSpec.describe Magick::Image, '#transparent_color' do
  it 'returns the name in sRGB for a CMYK image' do
    image = described_class.new(1, 1) { |info| info.depth = 16 }
    image.colorspace = Magick::CMYKColorspace

    expect(image.transparent_color).to eq('#0000000000000000')
    image.transparent_color = 'red'
    expect(image.transparent_color).to eq('#FFFF00000000FFFF')
    name = image.transparent_color
    image.transparent_color = name
    expect(image.transparent_color).to eq('#FFFF00000000FFFF')
  end

  it 'returns a CMYK color name in sRGB' do
    image = described_class.new(1, 1) { |info| info.depth = 16 }
    image.transparent_color = 'cmyk(100%,0,0,0)'

    expect(image.transparent_color).to eq('#0000FFFFFFFFFFFF')
  end
end

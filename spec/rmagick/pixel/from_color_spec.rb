# frozen_string_literal: true

RSpec.describe Magick::Pixel, '.from_color' do
  it 'converts a CMYK color name to RGB' do
    pixel = described_class.from_color('cmyk(100%,0,0,0)')

    expect([pixel.red, pixel.green, pixel.blue, pixel.black]).to eq([0, Magick::QuantumRange, Magick::QuantumRange, 0])
    expect(pixel.alpha).to eq(Magick::QuantumRange)
  end

  it 'converts the black of a CMYK color name' do
    pixel = described_class.from_color('cmyk(0,0,0,100%)')

    expect([pixel.red, pixel.green, pixel.blue, pixel.black]).to eq([0, 0, 0, 0])

    pixel = described_class.from_color('cmyk(50%,0,0,50%)')

    expect([pixel.red, pixel.green, pixel.blue, pixel.black]).to eq([16_383, 32_767, 32_767, 0])
  end

  it 'keeps the alpha of a CMYK color name' do
    pixel = described_class.from_color('cmyka(100%,0,0,0,0.2)')

    expect([pixel.red, pixel.green, pixel.blue, pixel.black]).to eq([0, Magick::QuantumRange, Magick::QuantumRange, 0])
    expect(pixel.alpha).to eq(Magick::QuantumRange / 5)
  end
end

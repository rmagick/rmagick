# frozen_string_literal: true

RSpec.describe Magick::Image, '#to_color' do
  it 'works' do
    image = described_class.new(20, 20)
    red = Magick::Pixel.new(Magick::QuantumRange)

    result = image.to_color(red)
    expect(result).to eq('red')
  end

  it 'uses the depth of the image' do
    pixel = Magick::Pixel.new(1234, 5678, 9012)

    expect(described_class.new(1, 1) { |options| options.depth = 8 }.to_color(pixel)).to eq('#051623')
    expect(described_class.new(1, 1) { |options| options.depth = 16 }.to_color(pixel)).to eq('#04D2162E2334')
  end

  it 'includes the alpha value only when the image has an alpha channel' do
    pixel = Magick::Pixel.new(1234, 5678, 9012)
    pixel.alpha = 32_896
    image = described_class.new(1, 1) { |options| options.depth = 8 }

    expect(image.to_color(pixel)).to eq('#051623')
    image.alpha(Magick::ActivateAlphaChannel)
    expect(image.to_color(pixel)).to eq('#05162380')
  end

  it 'converts a color name to CMYK for a CMYK image' do
    image = described_class.new(1, 1) { |options| options.depth = 8 }
    image.colorspace = Magick::CMYKColorspace

    expect(image.to_color('red')).to eq('#00FFFF00')
    expect(image.to_color('cmyk(0,255,255,0)')).to eq('#00FFFF00')
  end

  it 'includes the black value of a pixel of a CMYK image' do
    image = described_class.new(1, 1) do |options|
      options.background_color = 'gray50'
      options.depth = 8
    end
    image.colorspace = Magick::CMYKColorspace

    expect(image.to_color(image.pixel_color(0, 0))).to eq('#00000080')
  end
end

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
end

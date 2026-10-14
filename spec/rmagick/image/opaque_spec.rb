# frozen_string_literal: true

RSpec.describe Magick::Image, '#opaque' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.opaque('white', 'red')
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    red = Magick::Pixel.new(Magick::QuantumRange)
    blue = Magick::Pixel.new(0, 0, Magick::QuantumRange)
    expect { image.opaque(red, blue) }.not_to raise_error
    expect { image.opaque(red, 2) }.to raise_error(TypeError)
    expect { image.opaque(2, blue) }.to raise_error(TypeError)
  end

  it 'matches the black of a CMYK color' do
    image = described_class.new(2, 1)
    image.colorspace = Magick::CMYKColorspace
    black = Magick::Pixel.new(0, 0, 0)
    black.black = Magick::QuantumRange
    image.pixel_color(0, 0, black)

    result = image.opaque(black, Magick::Pixel.new(0, Magick::QuantumRange, 0))

    expect(result.get_pixels(0, 0, 2, 1).map { |pixel| [pixel.green, pixel.black] }).to eq([[Magick::QuantumRange, 0], [0, 0]])
  end

  it 'converts color names to CMYK for a CMYK image' do
    image = described_class.new(2, 1)
    image.pixel_color(0, 0, 'black')
    image.colorspace = Magick::CMYKColorspace

    pixels = image.opaque('black', 'red').get_pixels(0, 0, 2, 1)

    expect(pixels.map { |pixel| [pixel.cyan, pixel.magenta, pixel.yellow, pixel.black] }).to eq([[0, Magick::QuantumRange, Magick::QuantumRange, 0], [0, 0, 0, 0]])
  end
end

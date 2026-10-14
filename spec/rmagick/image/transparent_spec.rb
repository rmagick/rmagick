# frozen_string_literal: true

RSpec.describe Magick::Image, '#transparent' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.transparent('white')
    expect(result).to be_instance_of(described_class)

    pixel = Magick::Pixel.new
    expect { image.transparent(pixel) }.not_to raise_error
    expect { image.transparent('white', Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { image.transparent('white', alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { image.transparent('white', wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { image.transparent('white', alpha: Magick::TransparentAlpha, extra: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { image.transparent('white', Magick::TransparentAlpha, 2) }.to raise_error(ArgumentError)
    expect { image.transparent('white', Magick::QuantumRange / 2) }.to raise_error(ArgumentError)
    expect { image.transparent(2) }.to raise_error(TypeError)
  end

  it 'clamps an out-of-range alpha unless ImageMagick uses HDRI' do
    image = described_class.new(1, 1)

    alpha = image.transparent('white', alpha: Magick::QuantumRange + 1).pixel_color(0, 0).alpha
    expect(alpha).to eq(Magick::Magick_features.include?('HDRI') ? Magick::QuantumRange + 1 : Magick::QuantumRange)
  end

  it 'matches the black of a CMYK color' do
    image = described_class.new(2, 1)
    image.colorspace = Magick::CMYKColorspace
    black = Magick::Pixel.new(0, 0, 0)
    black.black = Magick::QuantumRange
    image.pixel_color(0, 0, black)

    alphas = image.transparent(black).get_pixels(0, 0, 2, 1).map(&:alpha)

    expect(alphas).to eq([Magick::TransparentAlpha, Magick::OpaqueAlpha])
  end
end

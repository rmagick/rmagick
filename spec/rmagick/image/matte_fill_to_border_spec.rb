# frozen_string_literal: true

RSpec.describe Magick::Image, '#matte_fill_to_border' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.matte_fill_to_border(image.columns / 2, image.rows / 2)
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    expect { image.matte_fill_to_border(image.columns, image.rows) }.not_to raise_error
    expect { image.matte_fill_to_border(image.columns + 1, image.rows) }.to raise_error(ArgumentError)
    expect { image.matte_fill_to_border(image.columns, image.rows + 1) }.to raise_error(ArgumentError)
  end

  it 'stops at the border color of a CMYK image' do
    image = described_class.new(3, 1)
    image.pixel_color(1, 0, 'black')
    image.colorspace = Magick::CMYKColorspace
    image.border_color = 'black'

    # ImageMagick 6 reads past the row when it fills a CMYK image rightward.
    alphas = image.matte_fill_to_border(2, 0).get_pixels(0, 0, 3, 1).map(&:alpha)

    expect(alphas).to eq([Magick::OpaqueAlpha, Magick::OpaqueAlpha, Magick::TransparentAlpha])
  end

  it 'stops at a border color given as a Pixel of a CMYK image' do
    image = described_class.new(3, 1)
    image.colorspace = Magick::CMYKColorspace
    image.pixel_color(1, 0, Magick::Pixel.new(0, Magick::QuantumRange, Magick::QuantumRange))
    image.border_color = image.pixel_color(1, 0)

    # ImageMagick 6 reads past the row when it fills a CMYK image rightward.
    alphas = image.matte_fill_to_border(2, 0).get_pixels(0, 0, 3, 1).map(&:alpha)

    expect(alphas).to eq([Magick::OpaqueAlpha, Magick::OpaqueAlpha, Magick::TransparentAlpha])
  end
end

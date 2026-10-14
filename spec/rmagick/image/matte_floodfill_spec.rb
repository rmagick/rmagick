# frozen_string_literal: true

RSpec.describe Magick::Image, '#matte_floodfill' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.matte_floodfill(image.columns / 2, image.rows / 2)
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    expect { image.matte_floodfill(image.columns, image.rows) }.not_to raise_error

    Magick::PaintMethod.values do |method|
      next if [Magick::FillToBorderMethod, Magick::FloodfillMethod].include?(method)

      expect { image.matte_flood_fill('blue', Magick::TransparentAlpha, image.columns, image.rows, method) }.to raise_error(ArgumentError)
    end
    expect { image.matte_floodfill(image.columns + 1, image.rows) }.to raise_error(ArgumentError)
    expect { image.matte_floodfill(image.columns, image.rows + 1) }.to raise_error(ArgumentError)
    expect { image.matte_flood_fill('blue', image.columns, image.rows, Magick::FloodfillMethod, alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { image.matte_flood_fill('blue', image.columns, image.rows, Magick::FloodfillMethod, wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
  end

  it 'changes the specified color to transparent' do
    image = described_class.new(1, 1)
    color = image.pixel_color(0, 0)
    expect(color.alpha).to eq(Magick::OpaqueAlpha)

    result = image.matte_floodfill(0, 0)

    color = result.pixel_color(0, 0)
    expect(color.alpha).to eq(Magick::TransparentAlpha)
  end

  it 'fills only the pixels with the black of a CMYK image' do
    image = described_class.new(2, 1)
    image.colorspace = Magick::CMYKColorspace
    black = Magick::Pixel.new(0, 0, 0)
    black.black = Magick::QuantumRange
    image.pixel_color(1, 0, black)

    # ImageMagick 6 reads past the row when it fills a CMYK image rightward.
    alphas = image.matte_floodfill(1, 0).get_pixels(0, 0, 2, 1).map(&:alpha)

    expect(alphas).to eq([Magick::OpaqueAlpha, Magick::TransparentAlpha])
  end
end

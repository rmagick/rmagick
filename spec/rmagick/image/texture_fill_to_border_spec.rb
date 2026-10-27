# frozen_string_literal: true

RSpec.describe Magick::Image, '#texture_fill_to_border' do
  it 'works' do
    image = described_class.new(20, 20)
    texture = described_class.read('granite:').first

    result = image.texture_fill_to_border(image.columns / 2, image.rows / 2, texture)
    expect(result).to be_instance_of(described_class)

    expect { image.texture_fill_to_border(image.columns / 2, image.rows / 2, 'x') }.to raise_error(NoMethodError)
    expect { image.texture_fill_to_border(image.columns * 2, image.rows, texture) }.to raise_error(ArgumentError)
    expect { image.texture_fill_to_border(image.columns, image.rows * 2, texture) }.to raise_error(ArgumentError)

    Magick::PaintMethod.values do |method|
      next if [Magick::FillToBorderMethod, Magick::FloodfillMethod].include?(method)

      expect { image.texture_flood_fill('blue', texture, image.columns, image.rows, method) }.to raise_error(ArgumentError)
    end
  end

  it 'stops at the border color of a CMYK image' do
    image = described_class.new(3, 1)
    image.pixel_color(1, 0, 'black')
    image.colorspace = Magick::CMYKColorspace
    image.border_color = 'black'
    texture = described_class.new(1, 1) { |info| info.background_color = 'red' }

    # ImageMagick 6 reads past the row when it fills a CMYK image rightward.
    result = image.texture_fill_to_border(2, 0, texture)

    expect(result.get_pixels(0, 0, 2, 1)).to eq(image.get_pixels(0, 0, 2, 1))
    expect(result.pixel_color(2, 0)).not_to eq(image.pixel_color(2, 0))
  end

  it 'stops at a border color given as a Pixel of a CMYK image' do
    image = described_class.new(3, 1)
    image.colorspace = Magick::CMYKColorspace
    image.pixel_color(1, 0, Magick::Pixel.new(0, Magick::QuantumRange, Magick::QuantumRange))
    image.border_color = image.pixel_color(1, 0)
    texture = described_class.new(1, 1) { |info| info.background_color = 'blue' }

    # ImageMagick 6 reads past the row when it fills a CMYK image rightward.
    result = image.texture_fill_to_border(2, 0, texture)

    expect(result.get_pixels(0, 0, 2, 1)).to eq(image.get_pixels(0, 0, 2, 1))
    expect(result.pixel_color(2, 0)).not_to eq(image.pixel_color(2, 0))
  end
end

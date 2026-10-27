# frozen_string_literal: true

RSpec.describe Magick::Image, "#color_fill_to_border" do
  it "works" do
    image = described_class.new(20, 20)

    expect { image.color_fill_to_border(-1, 1, 'red') }.to raise_error(ArgumentError)
    expect { image.color_fill_to_border(1, 100, 'red') }.to raise_error(ArgumentError)

    result = image.color_fill_to_border(image.columns / 2, image.rows / 2, 'red')
    expect(result).to be_instance_of(described_class)

    pixel = Magick::Pixel.new(Magick::QuantumRange)
    expect { image.color_fill_to_border(image.columns / 2, image.rows / 2, pixel) }.not_to raise_error
  end

  it 'stops at the border color of a CMYK image' do
    image = described_class.new(3, 1)
    image.pixel_color(1, 0, 'black')
    image.colorspace = Magick::CMYKColorspace
    image.border_color = 'black'

    # ImageMagick 6 reads past the row when it fills a CMYK image rightward.
    pixels = image.color_fill_to_border(2, 0, 'red').get_pixels(0, 0, 3, 1)

    expect(pixels.map { |pixel| [pixel.cyan, pixel.magenta, pixel.yellow, pixel.black] }).to eq([[0, 0, 0, 0], [0, 0, 0, Magick::QuantumRange], [0, Magick::QuantumRange, Magick::QuantumRange, 0]])
  end
end

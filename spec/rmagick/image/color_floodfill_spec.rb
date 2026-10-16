# frozen_string_literal: true

RSpec.describe Magick::Image, "#color_floodfill" do
  it "works" do
    image = described_class.new(20, 20)

    expect { image.color_floodfill(-1, 1, 'red') }.to raise_error(ArgumentError)
    expect { image.color_floodfill(1, 100, 'red') }.to raise_error(ArgumentError)

    result = image.color_floodfill(image.columns / 2, image.rows / 2, 'red')
    expect(result).to be_instance_of(described_class)

    pixel = Magick::Pixel.new(Magick::QuantumRange)
    expect { image.color_floodfill(image.columns / 2, image.rows / 2, pixel) }.not_to raise_error
  end

  it 'fills only the pixels with the black of a CMYK image' do
    image = described_class.new(2, 1)
    image.colorspace = Magick::CMYKColorspace
    black = Magick::Pixel.new(0, 0, 0)
    black.black = Magick::QuantumRange
    image.pixel_color(1, 0, black)

    # ImageMagick 6 reads past the row when it fills a CMYK image rightward.
    pixels = image.color_floodfill(1, 0, Magick::Pixel.new(0, Magick::QuantumRange, 0)).get_pixels(0, 0, 2, 1)

    expect(pixels[1].black).to eq(0)
    expect(pixels[0]).to eq(image.pixel_color(0, 0))
  end

  it 'converts color names to CMYK for a CMYK image' do
    image = described_class.new(2, 1)
    image.pixel_color(1, 0, 'black')
    image.colorspace = Magick::CMYKColorspace

    # ImageMagick 6 reads past the row when it fills a CMYK image rightward.
    pixels = image.color_flood_fill('black', 'red', 1, 0, Magick::FloodfillMethod).get_pixels(0, 0, 2, 1)

    expect(pixels.map { |pixel| [pixel.cyan, pixel.magenta, pixel.yellow, pixel.black] }).to eq([[0, 0, 0, 0], [0, Magick::QuantumRange, Magick::QuantumRange, 0]])
  end

  it "releases what it holds when one of its calls is interrupted" do
    image = described_class.new(4, 4)

    expect(interrupt_each_call(Class.new(StandardError)) { image.color_floodfill(1, 1, "red") }).to be_positive
  end
end

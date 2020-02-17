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
end

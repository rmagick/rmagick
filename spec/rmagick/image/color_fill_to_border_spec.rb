RSpec.describe Magick::Image, "#color_fill_to_border" do
  it "works" do
    image = described_class.new(20, 20)

    expect { image.color_fill_to_border(-1, 1, 'red') }.to raise_error(ArgumentError)
    expect { image.color_fill_to_border(1, 100, 'red') }.to raise_error(ArgumentError)

    res = image.color_fill_to_border(image.columns / 2, image.rows / 2, 'red')
    expect(res).to be_instance_of(described_class)

    pixel = Magick::Pixel.new(Magick::QuantumRange)
    expect { image.color_fill_to_border(image.columns / 2, image.rows / 2, pixel) }.not_to raise_error
  end
end

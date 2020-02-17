RSpec.describe Magick::Image, "#color_point" do
  it "works" do
    image = described_class.new(20, 20)

    res = image.color_point(0, 0, 'red')
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(image)

    pixel = Magick::Pixel.new(Magick::QuantumRange)
    expect { image.color_point(0, 0, pixel) }.not_to raise_error
  end
end

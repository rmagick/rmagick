RSpec.describe Magick::Image, "#color_fill_to_border" do
  it "works" do
    img = described_class.new(20, 20)

    expect { img.color_fill_to_border(-1, 1, 'red') }.to raise_error(ArgumentError)
    expect { img.color_fill_to_border(1, 100, 'red') }.to raise_error(ArgumentError)
    expect do
      res = img.color_fill_to_border(img.columns / 2, img.rows / 2, 'red')
      expect(res).to be_instance_of(described_class)
    end.not_to raise_error
    pixel = Magick::Pixel.new(Magick::QuantumRange)
    expect { img.color_fill_to_border(img.columns / 2, img.rows / 2, pixel) }.not_to raise_error
  end
end

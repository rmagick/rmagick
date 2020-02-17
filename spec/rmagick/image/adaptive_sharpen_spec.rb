RSpec.describe Magick::Image, "#adaptive_sharpen" do
  it "works" do
    image = described_class.new(20, 20)

    result = image.adaptive_sharpen
    expect(result).to be_instance_of(described_class)

    expect { image.adaptive_sharpen(2) }.not_to raise_error
    expect { image.adaptive_sharpen(3, 2) }.not_to raise_error
    expect { image.adaptive_sharpen(3, 2, 2) }.to raise_error(ArgumentError)
  end
end

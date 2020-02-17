RSpec.describe Magick::Image, "#adaptive_blur" do
  it "works" do
    image = described_class.new(20, 20)

    result = image.adaptive_blur
    expect(result).to be_instance_of(described_class)

    expect { image.adaptive_blur(2) }.not_to raise_error
    expect { image.adaptive_blur(3, 2) }.not_to raise_error
    expect { image.adaptive_blur(3, 2, 2) }.to raise_error(ArgumentError)
  end
end

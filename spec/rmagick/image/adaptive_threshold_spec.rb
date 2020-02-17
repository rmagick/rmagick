RSpec.describe Magick::Image, "#adaptive_threshold" do
  it "works" do
    image = described_class.new(20, 20)

    result = image.adaptive_threshold
    expect(result).to be_instance_of(described_class)

    expect { image.adaptive_threshold(2) }.not_to raise_error
    expect { image.adaptive_threshold(2, 4) }.not_to raise_error
    expect { image.adaptive_threshold(2, 4, 1) }.not_to raise_error
    expect { image.adaptive_threshold(2, 4, 1, 2) }.to raise_error(ArgumentError)
  end
end

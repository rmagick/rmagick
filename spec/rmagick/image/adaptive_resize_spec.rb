RSpec.describe Magick::Image, "#adaptive_resize" do
  it "works" do
    image = described_class.new(20, 20)

    result = image.adaptive_resize(10, 10)
    expect(result).to be_instance_of(described_class)

    expect { image.adaptive_resize(2) }.not_to raise_error
    expect { image.adaptive_resize(-1.0) }.to raise_error(ArgumentError)
    expect { image.adaptive_resize(10, 10, 10) }.to raise_error(ArgumentError)
    expect { image.adaptive_resize }.to raise_error(ArgumentError)
    expect { image.adaptive_resize(Float::MAX) }.to raise_error(RangeError)
  end
end

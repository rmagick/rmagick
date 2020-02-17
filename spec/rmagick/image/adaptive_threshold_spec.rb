RSpec.describe Magick::Image, "#adaptive_threshold" do
  it "works" do
    img = described_class.new(20, 20)

    res = img.adaptive_threshold
    expect(res).to be_instance_of(described_class)

    expect { img.adaptive_threshold(2) }.not_to raise_error
    expect { img.adaptive_threshold(2, 4) }.not_to raise_error
    expect { img.adaptive_threshold(2, 4, 1) }.not_to raise_error
    expect { img.adaptive_threshold(2, 4, 1, 2) }.to raise_error(ArgumentError)
  end
end

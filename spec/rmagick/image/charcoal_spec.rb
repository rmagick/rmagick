RSpec.describe Magick::Image, "#charcoal" do
  it "works" do
    image = described_class.new(20, 20)

    res = image.charcoal
    expect(res).to be_instance_of(described_class)

    expect { image.charcoal(1.0) }.not_to raise_error
    expect { image.charcoal(1.0, 2.0) }.not_to raise_error
    expect { image.charcoal(1.0, 2.0, 3.0) }.to raise_error(ArgumentError)
  end
end

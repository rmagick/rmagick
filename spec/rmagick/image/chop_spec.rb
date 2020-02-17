RSpec.describe Magick::Image, "#chop" do
  it "works" do
    image = described_class.new(20, 20)

    result = image.chop(10, 10, 10, 10)
    expect(result).to be_instance_of(described_class)
  end
end

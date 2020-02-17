RSpec.describe Magick::Image, "#chop" do
  it "works" do
    image = described_class.new(20, 20)

    res = image.chop(10, 10, 10, 10)
    expect(res).to be_instance_of(described_class)
  end
end

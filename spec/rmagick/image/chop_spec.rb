RSpec.describe Magick::Image, "#chop" do
  it "works" do
    img = described_class.new(20, 20)

    res = img.chop(10, 10, 10, 10)
    expect(res).to be_instance_of(described_class)
  end
end

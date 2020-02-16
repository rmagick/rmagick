RSpec.describe Magick::Image, "#changed?" do
  it "works" do
    skip 'image is initially changed'

    img = described_class.new(20, 20)

    expect(img.changed?).to be(false)
    img.pixel_color(0, 0, 'red')
    expect(img.changed?).to be(true)
  end
end

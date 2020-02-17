RSpec.describe Magick::Image, "#changed?" do
  it "works" do
    skip 'image is initially changed'

    image = described_class.new(20, 20)

    expect(image.changed?).to be(false)
    image.pixel_color(0, 0, 'red')
    expect(image.changed?).to be(true)
  end
end

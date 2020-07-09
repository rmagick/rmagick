RSpec.describe Magick::Image, "#changed?" do
  it "returns true when a new image is instantiated" do
    image = described_class.new(2, 2)

    expect(image.changed?).to be(true)
  end

  it "returns false after an image is loaded from disk" do
    image = described_class.read(FLOWER_HAT).first

    expect(image.changed?).to be(false)
  end

  it "returns true when a pixel in the image was changed" do
    image = described_class.read(FLOWER_HAT).first

    image.import_pixels(0, 0, 1, 1, "RGB", [45, 98, 156])

    expect(image.changed?).to be(true)
  end

  it "still returns true after it has been persisted" do
    image = described_class.read(FLOWER_HAT).first

    image.import_pixels(0, 0, 1, 1, "RGB", [45, 98, 156])
    image.write("./tmp/test_changed_predicate.jpg")

    expect(image.changed?).to be(true)
  end
end

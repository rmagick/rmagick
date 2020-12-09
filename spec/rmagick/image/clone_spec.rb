RSpec.describe Magick::Image, "#clone" do
  it "returns a new copy of the image" do
    image = build_image

    new_image = image.clone

    expect(new_image).to eq(image)
    expect(new_image).not_to be(image)
    expect(new_image.export_pixels).to eq(image.export_pixels)
  end

  it "returns a non-frozen copy of the image when it is not frozen" do
    image = build_image

    new_image = image.clone

    expect(new_image.frozen?).to be(false)
  end

  it "returns a frozen copy of the image when it is frozen" do
    image = build_image

    image.freeze
    new_image = image.clone

    expect(new_image.frozen?).to be(true)
  end
end

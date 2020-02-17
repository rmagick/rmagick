RSpec.describe Magick::Image, "#alpha" do
  it "works" do
    image = described_class.new(20, 20)

    expect { image.alpha }.not_to raise_error
    expect(image.alpha).to be(false)
    expect { image.alpha Magick::ActivateAlphaChannel }.not_to raise_error
    expect(image.alpha).to be(true)
  end
end

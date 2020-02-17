RSpec.describe Magick::Image, "#spaceship" do
  it "works" do
    image0 = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    image1 = described_class.read(IMAGES_DIR + '/Button_1.gif').first
    sig0 = image0.signature
    sig1 = image1.signature

    # since <=> is based on the signature, the images should
    # have the same relationship to each other as their
    # signatures have to each other.
    expect(image0 <=> image1).to eq(sig0 <=> sig1)
    expect(image1 <=> image0).to eq(sig1 <=> sig0)
    expect(image0).to eq(image0)
    expect(image1).not_to eq(image0)
    expect(image0 <=> nil).to be(nil)
  end
end

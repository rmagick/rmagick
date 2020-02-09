RSpec.describe Magick::Image, "#spaceship" do
  before do
    @img = described_class.new(20, 20)
  end

  it "works" do
    img0 = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    img1 = described_class.read(IMAGES_DIR + '/Button_1.gif').first
    sig0 = img0.signature
    sig1 = img1.signature
    # since <=> is based on the signature, the images should
    # have the same relationship to each other as their
    # signatures have to each other.
    expect(img0 <=> img1).to eq(sig0 <=> sig1)
    expect(img1 <=> img0).to eq(sig1 <=> sig0)
    expect(img0).to eq(img0)
    expect(img1).not_to eq(img0)
    expect(img0 <=> nil).to be(nil)
  end
end

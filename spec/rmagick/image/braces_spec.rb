RSpec.describe Magick::Image, "#[]" do
  it "works" do
    img = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    expect(img[nil]).to be(nil)
    expect(img['label']).to be(nil)
    expect(img[:comment]).to match(/^Creator: PolyView/)
  end
end

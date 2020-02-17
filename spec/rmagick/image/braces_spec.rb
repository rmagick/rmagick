RSpec.describe Magick::Image, "#[]" do
  it "works" do
    image = described_class.read(IMAGES_DIR + '/Button_0.gif').first
    expect(image[nil]).to be(nil)
    expect(image['label']).to be(nil)
    expect(image[:comment]).to match(/^Creator: PolyView/)
  end
end

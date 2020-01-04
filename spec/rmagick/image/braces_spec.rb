RSpec.describe Magick::Image, "#[]" do
  before do
    @img = Magick::Image.new(20, 20)
  end

  it "works" do
    img = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    expect(img[nil]).to be(nil)
    expect(img['label']).to be(nil)
    expect(img[:comment]).to match(/^Creator: PolyView/)
  end
end

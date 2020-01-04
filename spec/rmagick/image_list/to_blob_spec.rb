RSpec.describe Magick::ImageList, "#to_blob" do
  before do
    @ilist = Magick::ImageList.new
  end

  it "works" do
    @ilist.read(IMAGES_DIR + '/Button_0.gif')
    blob = nil
    expect { blob = @ilist.to_blob }.not_to raise_error
    img = @ilist.from_blob(blob)
    expect(img[0]).to eq(@ilist[0])
    expect(img.scene).to eq(1)
  end
end

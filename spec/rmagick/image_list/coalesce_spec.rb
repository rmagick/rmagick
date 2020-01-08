RSpec.describe Magick::ImageList, "#coalesce" do
  before do
    @ilist = Magick::ImageList.new
  end

  it "works" do
    @ilist.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_0.gif')
    ilist = nil
    expect { ilist = @ilist.coalesce }.not_to raise_error
    expect(ilist).to be_instance_of(Magick::ImageList)
    expect(ilist.length).to eq(2)
    expect(ilist.scene).to eq(0)
  end
end

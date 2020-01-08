RSpec.describe Magick::ImageList, "#from_blob" do
  before do
    @ilist = Magick::ImageList.new
  end

  it "works" do
    hat = File.open(FLOWER_HAT, 'rb')
    blob = hat.read
    expect { @ilist.from_blob(blob) }.not_to raise_error
    expect(@ilist[0]).to be_instance_of(Magick::Image)
    expect(@ilist.scene).to eq(0)

    ilist2 = Magick::ImageList.new(FLOWER_HAT)
    expect(ilist2).to eq(@ilist)
  end
end

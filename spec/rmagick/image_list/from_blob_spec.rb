RSpec.describe Magick::ImageList, "#from_blob" do
  before do
    @ilist = described_class.new
  end

  it "works" do
    blob = File.read(FLOWER_HAT, mode: "rb")

    expect { @ilist.from_blob(blob) }.not_to raise_error
    expect(@ilist[0]).to be_instance_of(Magick::Image)
    expect(@ilist.scene).to eq(0)

    ilist2 = described_class.new(FLOWER_HAT)
    expect(ilist2).to eq(@ilist)
  end
end

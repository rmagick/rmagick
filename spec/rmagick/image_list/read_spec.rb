RSpec.describe Magick::ImageList, "#read" do
  before do
    @ilist = described_class.new
  end

  it "works" do
    expect { @ilist.read(FLOWER_HAT) }.not_to raise_error
    expect(@ilist.length).to eq(1)
    expect(@ilist.scene).to eq(0)
    expect { @ilist.read(FLOWER_HAT, FLOWER_HAT) }.not_to raise_error
    expect(@ilist.length).to eq(3)
    expect(@ilist.scene).to eq(2)
    expect { @ilist.read(FLOWER_HAT) { self.background_color = 'red ' } }.not_to raise_error
    expect(@ilist.length).to eq(4)
    expect(@ilist.scene).to eq(3)
  end
end

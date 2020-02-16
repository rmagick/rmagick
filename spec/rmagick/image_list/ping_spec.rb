RSpec.describe Magick::ImageList, "#ping" do
  it "works" do
    ilist = described_class.new

    expect { ilist.ping(FLOWER_HAT) }.not_to raise_error
    expect(ilist.length).to eq(1)
    expect(ilist.scene).to eq(0)
    expect { ilist.ping(FLOWER_HAT, FLOWER_HAT) }.not_to raise_error
    expect(ilist.length).to eq(3)
    expect(ilist.scene).to eq(2)
    expect { ilist.ping(FLOWER_HAT) { self.background_color = 'red ' } }.not_to raise_error
    expect(ilist.length).to eq(4)
    expect(ilist.scene).to eq(3)
  end
end

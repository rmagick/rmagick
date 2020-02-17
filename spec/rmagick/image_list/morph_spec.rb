RSpec.describe Magick::ImageList, "#morph" do
  it "works" do
    ilist = described_class.new

    # can't morph an empty list
    expect { ilist.morph(1) }.to raise_error(ArgumentError)
    ilist.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_1.gif')
    # can't specify a negative argument
    expect { ilist.morph(-1) }.to raise_error(ArgumentError)

    result = ilist.morph(2)
    expect(result).to be_instance_of(described_class)
    expect(result.length).to eq(4)
    expect(result.scene).to eq(0)
  end
end

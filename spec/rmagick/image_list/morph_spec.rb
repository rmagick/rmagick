RSpec.describe Magick::ImageList, "#morph" do
  before do
    @ilist = described_class.new
  end

  it "works" do
    # can't morph an empty list
    expect { @ilist.morph(1) }.to raise_error(ArgumentError)
    @ilist.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_1.gif')
    # can't specify a negative argument
    expect { @ilist.morph(-1) }.to raise_error(ArgumentError)
    expect do
      res = @ilist.morph(2)
      expect(res).to be_instance_of(described_class)
      expect(res.length).to eq(4)
      expect(res.scene).to eq(0)
    end.not_to raise_error
  end
end

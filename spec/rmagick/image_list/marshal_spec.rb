RSpec.describe Magick::ImageList, "#marshal" do
  before do
    @ilist = described_class.new
  end

  it "works" do
    ilist1 = described_class.new(*Dir[IMAGES_DIR + '/Button_*.gif'])
    d = nil
    ilist2 = nil
    expect { d = Marshal.dump(ilist1) }.not_to raise_error
    expect { ilist2 = Marshal.load(d) }.not_to raise_error
    expect(ilist2).to eq(ilist1)
  end
end

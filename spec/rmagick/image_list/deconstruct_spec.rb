RSpec.describe Magick::ImageList, "#deconstruct" do
  before do
    @ilist = described_class.new
  end

  it "works" do
    @ilist.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_1.gif')
    ilist = nil
    expect { ilist = @ilist.deconstruct }.not_to raise_error
    expect(ilist).to be_instance_of(described_class)
    expect(ilist.length).to eq(2)
    expect(ilist.scene).to eq(0)
  end
end

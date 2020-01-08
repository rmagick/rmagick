RSpec.describe Magick::ImageList, "#dup" do
  before do
    @ilist = Magick::ImageList.new
  end

  it "works" do
    @ilist.read(*Dir[IMAGES_DIR + '/Button_*.gif'])
    ilist2 = @ilist.dup
    expect(@ilist).to eq(ilist2)
    expect(ilist2.frozen?).to eq(@ilist.frozen?)
    @ilist.freeze
    ilist2 = @ilist.dup
    expect(ilist2.frozen?).not_to eq(@ilist.frozen?)
  end
end

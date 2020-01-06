RSpec.describe Magick::ImageList, "#clone" do
  it "works" do
    ilist = described_class.new

    ilist.read(*Dir[IMAGES_DIR + '/Button_*.gif'])
    ilist2 = ilist.clone
    expect(ilist).to eq(ilist2)
    expect(ilist2.frozen?).to eq(ilist.frozen?)
    ilist.freeze
    ilist2 = ilist.clone
    expect(ilist2.frozen?).to eq(ilist.frozen?)
  end
end

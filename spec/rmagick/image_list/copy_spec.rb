RSpec.describe Magick::ImageList, "#copy" do
  it "works" do
    ilist = described_class.new

    ilist.read(*Dir[IMAGES_DIR + '/Button_*.gif'])
    ilist.scene = 7
    ilist2 = ilist.copy
    expect(ilist2).not_to be(ilist)
    expect(ilist2.scene).to eq(ilist.scene)
    ilist.each_with_index do |img, x|
      expect(ilist2[x]).to eq(img)
    end
  end
end

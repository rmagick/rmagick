RSpec.describe Magick::ImageList, "#coalesce" do
  it "works" do
    ilist1 = described_class.new

    ilist1.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_0.gif')
    ilist2 = nil
    expect { ilist2 = ilist1.coalesce }.not_to raise_error
    expect(ilist2).to be_instance_of(described_class)
    expect(ilist2.length).to eq(2)
    expect(ilist2.scene).to eq(0)
  end
end

RSpec.describe Magick::ImageList, "#to_blob" do
  it "works" do
    ilist = described_class.new

    ilist.read(IMAGES_DIR + '/Button_0.gif')
    blob = nil
    expect { blob = ilist.to_blob }.not_to raise_error
    image = ilist.from_blob(blob)
    expect(image[0]).to eq(ilist[0])
    expect(image.scene).to eq(1)
  end
end

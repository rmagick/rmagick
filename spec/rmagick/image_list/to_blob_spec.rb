RSpec.describe Magick::ImageList, "#to_blob" do
  it "works" do
    image_list = described_class.new

    image_list.read(IMAGES_DIR + '/Button_0.gif')
    blob = nil
    expect { blob = image_list.to_blob }.not_to raise_error
    image = image_list.from_blob(blob)
    expect(image[0]).to eq(image_list[0])
    expect(image.scene).to eq(1)
  end
end

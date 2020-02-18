RSpec.describe Magick::ImageList, "#from_blob" do
  it "works" do
    image_list = described_class.new
    blob = File.read(FLOWER_HAT, mode: "rb")

    expect { image_list.from_blob(blob) }.not_to raise_error
    expect(image_list[0]).to be_instance_of(Magick::Image)
    expect(image_list.scene).to eq(0)

    image_list2 = described_class.new(FLOWER_HAT)
    expect(image_list2).to eq(image_list)
  end
end

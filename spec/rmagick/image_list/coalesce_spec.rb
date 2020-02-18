RSpec.describe Magick::ImageList, "#coalesce" do
  it "works" do
    image_list1 = described_class.new

    image_list1.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_0.gif')
    image_list2 = nil
    expect { image_list2 = image_list1.coalesce }.not_to raise_error
    expect(image_list2).to be_instance_of(described_class)
    expect(image_list2.length).to eq(2)
    expect(image_list2.scene).to eq(0)
  end
end

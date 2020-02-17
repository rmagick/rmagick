RSpec.describe Magick::ImageList, "#marshal" do
  it "works" do
    image_list1 = described_class.new(*Dir[IMAGES_DIR + '/Button_*.gif'])
    d = nil
    image_list2 = nil
    expect { d = Marshal.dump(image_list1) }.not_to raise_error
    expect { image_list2 = Marshal.load(d) }.not_to raise_error
    expect(image_list2).to eq(image_list1)
  end
end

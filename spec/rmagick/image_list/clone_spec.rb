RSpec.describe Magick::ImageList, "#clone" do
  it "works" do
    image_list = described_class.new

    image_list.read(*Dir[IMAGES_DIR + '/Button_*.gif'])
    image_list2 = image_list.clone
    expect(image_list).to eq(image_list2)
    expect(image_list2.frozen?).to eq(image_list.frozen?)
    image_list.freeze
    image_list2 = image_list.clone
    expect(image_list2.frozen?).to eq(image_list.frozen?)
  end
end

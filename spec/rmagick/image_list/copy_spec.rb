RSpec.describe Magick::ImageList, "#copy" do
  it "works" do
    image_list = described_class.new

    image_list.read(*Dir[IMAGES_DIR + '/Button_*.gif'])
    image_list.scene = 7
    image_list2 = image_list.copy
    expect(image_list2).not_to be(image_list)
    expect(image_list2.scene).to eq(image_list.scene)
    image_list.each_with_index do |image, x|
      expect(image_list2[x]).to eq(image)
    end
  end
end

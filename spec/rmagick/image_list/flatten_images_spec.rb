RSpec.describe Magick::ImageList, '#flatten_images' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    expect { list.flatten_images }.not_to raise_error
  end

  it "still works" do
    image_list = described_class.new
    image_list.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_1.gif')

    image = image_list.flatten_images
    expect(image).to be_instance_of(Magick::Image)
  end
end

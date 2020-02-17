RSpec.describe Magick::ImageList, '#flatten_images' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    expect { list.flatten_images }.not_to raise_error
  end

  it "still works" do
    ilist = described_class.new
    ilist.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_1.gif')

    img = ilist.flatten_images
    expect(img).to be_instance_of(Magick::Image)
  end
end

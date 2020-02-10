RSpec.describe Magick::ImageList, '#flatten_images' do
  before do
    @list = described_class.new(*FILES[0..9])
  end

  it 'works' do
    expect { @list.flatten_images }.not_to raise_error
  end

  it "still works" do
    ilist = described_class.new
    ilist.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_1.gif')
    expect do
      img = ilist.flatten_images
      expect(img).to be_instance_of(Magick::Image)
    end.not_to raise_error
  end
end

RSpec.describe Magick::ImageList, '#flatten_images' do
  before do
    @list = Magick::ImageList.new(*FILES[0..9])
    @list2 = Magick::ImageList.new # intersection is 5..9
    @list2 << @list[5]
    @list2 << @list[6]
    @list2 << @list[7]
    @list2 << @list[8]
    @list2 << @list[9]
  end

  it 'works' do
    expect { @list.flatten_images }.not_to raise_error
  end

  it "still works" do
    ilist = Magick::ImageList.new
    ilist.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_1.gif')
    expect do
      img = ilist.flatten_images
      expect(img).to be_instance_of(Magick::Image)
    end.not_to raise_error
  end
end

RSpec.describe Magick::ImageList, "#mosaic" do
  before do
    @ilist = Magick::ImageList.new
  end

  it "works" do
    @ilist.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_1.gif')
    expect do
      res = @ilist.mosaic
      expect(res).to be_instance_of(Magick::Image)
    end.not_to raise_error
  end

  it "raises an error when images is not set" do
    list = @ilist.copy
    list.instance_variable_set("@images", nil)
    expect { list.mosaic }.to raise_error(Magick::ImageMagickError)
  end
end

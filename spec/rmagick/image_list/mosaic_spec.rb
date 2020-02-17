RSpec.describe Magick::ImageList, "#mosaic" do
  it "works" do
    ilist = described_class.new
    ilist.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_1.gif')

    result = ilist.mosaic
    expect(result).to be_instance_of(Magick::Image)
  end

  it "raises an error when images is not set" do
    ilist = described_class.new
    list = ilist.copy

    list.instance_variable_set("@images", nil)
    expect { list.mosaic }.to raise_error(Magick::ImageMagickError)
  end
end

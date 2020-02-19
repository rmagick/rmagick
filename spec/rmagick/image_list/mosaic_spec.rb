RSpec.describe Magick::ImageList, "#mosaic" do
  it "works" do
    image_list = described_class.new
    image_list.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_1.gif')

    result = image_list.mosaic
    expect(result).to be_instance_of(Magick::Image)
  end

  it "raises an error when images is not set" do
    image_list = described_class.new

    image_list.instance_variable_set("@images", nil)
    expect { image_list.mosaic }.to raise_error(Magick::ImageMagickError)
  end
end

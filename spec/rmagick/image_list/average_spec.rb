RSpec.describe Magick::ImageList, "#average" do
  it "works" do
    image_list = described_class.new

    image_list.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_0.gif')

    image = image_list.average
    expect(image).to be_instance_of(Magick::Image)

    expect { image_list.average(1) }.to raise_error(ArgumentError)
  end
end

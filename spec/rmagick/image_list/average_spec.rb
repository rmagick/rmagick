RSpec.describe Magick::ImageList, "#average" do
  it "works" do
    ilist = described_class.new

    ilist.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_0.gif')

    img = ilist.average
    expect(img).to be_instance_of(Magick::Image)

    expect { ilist.average(1) }.to raise_error(ArgumentError)
  end
end

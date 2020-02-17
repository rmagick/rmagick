RSpec.describe Magick::ImageList, "#morph" do
  it "works" do
    image_list = described_class.new

    # can't morph an empty list
    expect { image_list.morph(1) }.to raise_error(ArgumentError)
    image_list.read(IMAGES_DIR + '/Button_0.gif', IMAGES_DIR + '/Button_1.gif')
    # can't specify a negative argument
    expect { image_list.morph(-1) }.to raise_error(ArgumentError)

    result = image_list.morph(2)
    expect(result).to be_instance_of(described_class)
    expect(result.length).to eq(4)
    expect(result.scene).to eq(0)
  end
end

RSpec.describe Magick::ImageList, "#ping" do
  it "works" do
    image_list = described_class.new

    expect { image_list.ping(FLOWER_HAT) }.not_to raise_error
    expect(image_list.length).to eq(1)
    expect(image_list.scene).to eq(0)
    expect { image_list.ping(FLOWER_HAT, FLOWER_HAT) }.not_to raise_error
    expect(image_list.length).to eq(3)
    expect(image_list.scene).to eq(2)
    expect { image_list.ping(FLOWER_HAT) { self.background_color = 'red ' } }.not_to raise_error
    expect(image_list.length).to eq(4)
    expect(image_list.scene).to eq(3)
  end
end

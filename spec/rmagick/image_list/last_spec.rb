RSpec.describe Magick::ImageList, '#last' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    image = Magick::Image.new(5, 5)
    image_list << image
    image2 = nil
    expect { image2 = image_list.last }.not_to raise_error
    expect(image2).to be_instance_of(Magick::Image)
    expect(image).to eq(image2)
    image2 = Magick::Image.new(5, 5)
    image_list << image2
    image_list2 = nil
    expect { image_list2 = image_list.last(2) }.not_to raise_error
    expect(image_list2).to be_instance_of(described_class)
    expect(image_list2.length).to eq(2)
    expect(image_list2.scene).to eq(1)
    expect(image_list2[0]).to eq(image)
    expect(image_list2[1]).to eq(image2)
  end
end

RSpec.describe Magick::ImageList, '#uniq' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    expect { image_list.uniq }.not_to raise_error
    expect(image_list.uniq).to be_instance_of(described_class)
    image_list[1] = image_list[0]
    image_list.scene = 7
    image_list2 = image_list.uniq
    expect(image_list2.length).to eq(9)
    expect(image_list2.scene).to eq(6)
    expect(image_list.scene).to eq(7)
    image_list[6] = image_list[7]
    image_list2 = image_list.uniq
    expect(image_list2.length).to eq(8)
    expect(image_list2.scene).to eq(5)
    expect(image_list.scene).to eq(7)
  end
end

RSpec.describe Magick::ImageList, '#values_at' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])
    image_list2 = nil
    expect { image_list2 = image_list.values_at(1, 3, 5) }.not_to raise_error
    expect(image_list2).to be_instance_of(described_class)
    expect(image_list2.length).to eq(3)
    expect(image_list2.scene).to eq(2)
  end
end

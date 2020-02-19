RSpec.describe Magick::ImageList, '#compact' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    result = image_list.compact
    expect(image_list).not_to be(result)
    expect(image_list).to eq(result)

    result = image_list
    image_list.compact!
    expect(image_list).to be_instance_of(described_class)
    expect(image_list).to eq(result)
    expect(image_list).to be(result)
  end
end

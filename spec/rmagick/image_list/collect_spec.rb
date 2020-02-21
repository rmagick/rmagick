# rubocop:disable Style/CollectionMethods
RSpec.describe Magick::ImageList, '#collect' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    scene = image_list.scene
    result = image_list.collect(&:negate)
    expect(result).to be_instance_of(described_class)
    expect(image_list).not_to be(result)
    expect(result.scene).to eq(scene)

    scene = image_list.scene
    image_list.collect!(&:negate)
    expect(image_list).to be_instance_of(described_class)
    expect(image_list.scene).to eq(scene)
  end
end
# rubocop:enable Style/CollectionMethods

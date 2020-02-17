RSpec.describe Magick::ImageList, '#collect' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    scene = list.scene
    result = list.collect(&:negate)
    expect(result).to be_instance_of(described_class)
    expect(list).not_to be(result)
    expect(result.scene).to eq(scene)

    scene = list.scene
    list.collect!(&:negate)
    expect(list).to be_instance_of(described_class)
    expect(list.scene).to eq(scene)
  end
end

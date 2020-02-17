RSpec.describe Magick::ImageList, '#compact' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    result = list.compact
    expect(list).not_to be(result)
    expect(list).to eq(result)

    result = list
    list.compact!
    expect(list).to be_instance_of(described_class)
    expect(list).to eq(result)
    expect(list).to be(result)
  end
end

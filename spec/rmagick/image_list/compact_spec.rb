RSpec.describe Magick::ImageList, '#compact' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    res = list.compact
    expect(list).not_to be(res)
    expect(list).to eq(res)

    res = list
    list.compact!
    expect(list).to be_instance_of(described_class)
    expect(list).to eq(res)
    expect(list).to be(res)
  end
end

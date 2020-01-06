RSpec.describe Magick::ImageList, '#uniq' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    expect { list.uniq }.not_to raise_error
    expect(list.uniq).to be_instance_of(described_class)
    list[1] = list[0]
    list.scene = 7
    list2 = list.uniq
    expect(list2.length).to eq(9)
    expect(list2.scene).to eq(6)
    expect(list.scene).to eq(7)
    list[6] = list[7]
    list2 = list.uniq
    expect(list2.length).to eq(8)
    expect(list2.scene).to eq(5)
    expect(list.scene).to eq(7)
  end
end

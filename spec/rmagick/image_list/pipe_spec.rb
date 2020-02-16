RSpec.describe Magick::ImageList, '#|' do
  it 'works' do
    list = described_class.new(*FILES[0..9])
    list2 = described_class.new # intersection is 5..9
    list2 << list[5]
    list2 << list[6]
    list2 << list[7]
    list2 << list[8]
    list2 << list[9]

    expect do
      list.scene = 7
      # The or of these two lists should be the same as list
      # but not be the *same* list
      res = list | list2
      expect(res).to be_instance_of(described_class)
      expect(list).not_to be(res)
      expect(list2).not_to be(res)
      expect(list).to eq(res)
    end.not_to raise_error

    # Try or'ing disjoint lists
    temp_list = described_class.new(*FILES[10..14])
    res = list | temp_list
    expect(res).to be_instance_of(described_class)
    expect(res.length).to eq(15)
    expect(res.scene).to eq(7)

    expect { list | 2 }.to raise_error(ArgumentError)
    expect { list | [2] }.to raise_error(ArgumentError)
  end
end

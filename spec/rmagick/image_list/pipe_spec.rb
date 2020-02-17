RSpec.describe Magick::ImageList, '#|' do
  it 'works' do
    list = described_class.new(*FILES[0..9])
    list2 = described_class.new # intersection is 5..9
    list2 << list[5]
    list2 << list[6]
    list2 << list[7]
    list2 << list[8]
    list2 << list[9]

    list.scene = 7
    # The or of these two lists should be the same as list
    # but not be the *same* list
    result = list | list2
    expect(result).to be_instance_of(described_class)
    expect(list).not_to be(result)
    expect(list2).not_to be(result)
    expect(list).to eq(result)

    # Try or'ing disjoint lists
    temp_list = described_class.new(*FILES[10..14])
    result = list | temp_list
    expect(result).to be_instance_of(described_class)
    expect(result.length).to eq(15)
    expect(result.scene).to eq(7)

    expect { list | 2 }.to raise_error(ArgumentError)
    expect { list | [2] }.to raise_error(ArgumentError)
  end
end

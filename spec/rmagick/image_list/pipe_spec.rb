RSpec.describe Magick::ImageList, '#|' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])
    image_list2 = described_class.new # intersection is 5..9
    image_list2 << image_list[5]
    image_list2 << image_list[6]
    image_list2 << image_list[7]
    image_list2 << image_list[8]
    image_list2 << image_list[9]

    image_list.scene = 7
    # The or of these two lists should be the same as image_list
    # but not be the *same* image_list
    result = image_list | image_list2
    expect(result).to be_instance_of(described_class)
    expect(image_list).not_to be(result)
    expect(image_list2).not_to be(result)
    expect(image_list).to eq(result)

    # Try or'ing disjoint lists
    temp_list = described_class.new(*FILES[10..14])
    result = image_list | temp_list
    expect(result).to be_instance_of(described_class)
    expect(result.length).to eq(15)
    expect(result.scene).to eq(7)

    expect { image_list | 2 }.to raise_error(ArgumentError)
    expect { image_list | [2] }.to raise_error(ArgumentError)
  end
end

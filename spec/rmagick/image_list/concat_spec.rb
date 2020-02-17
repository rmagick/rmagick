RSpec.describe Magick::ImageList, '#concat' do
  it 'allows appending identical instances more than once' do
    image = Magick::Image.new(1, 1)
    image2 = Magick::Image.new(3, 3)
    list = described_class.new

    list.concat([image, image2, image, image2, image])

    result = list.append(false)
    expect(result.columns).to eq(9)
    expect(result.rows).to eq(3)
  end

  it 'works' do
    list = described_class.new(*FILES[0..9])
    list2 = described_class.new # intersection is 5..9
    list2 << list[5]
    list2 << list[6]
    list2 << list[7]
    list2 << list[8]
    list2 << list[9]

    result = list.concat(list2)
    expect(result).to be_instance_of(described_class)
    expect(result.length).to eq(15)
    expect(result.cur_image).to be(result[14])

    expect { list.concat(2) }.to raise_error(ArgumentError)
    expect { list.concat([2]) }.to raise_error(ArgumentError)
  end
end

RSpec.describe Magick::ImageList, '#concat' do
  it 'allows appending identical instances more than once' do
    image = Magick::Image.new(1, 1)
    image2 = Magick::Image.new(3, 3)
    image_list = described_class.new

    image_list.concat([image, image2, image, image2, image])

    result = image_list.append(false)
    expect(result.columns).to eq(9)
    expect(result.rows).to eq(3)
  end

  it 'works' do
    image_list = described_class.new(*FILES[0..9])
    image_list2 = described_class.new # intersection is 5..9
    image_list2 << image_list[5]
    image_list2 << image_list[6]
    image_list2 << image_list[7]
    image_list2 << image_list[8]
    image_list2 << image_list[9]

    result = image_list.concat(image_list2)
    expect(result).to be_instance_of(described_class)
    expect(result.length).to eq(15)
    expect(result.cur_image).to be(result[14])

    expect { image_list.concat(2) }.to raise_error(ArgumentError)
    expect { image_list.concat([2]) }.to raise_error(ArgumentError)
  end
end

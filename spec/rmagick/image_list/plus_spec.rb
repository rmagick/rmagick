RSpec.describe Magick::ImageList, '#+' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])
    image_list2 = described_class.new # intersection is 5..9
    image_list2 << image_list[5]
    image_list2 << image_list[6]
    image_list2 << image_list[7]
    image_list2 << image_list[8]
    image_list2 << image_list[9]

    image_list.scene = 7
    cur = image_list.cur_image

    result = image_list + image_list2
    expect(result).to be_instance_of(described_class)
    expect(result.length).to eq(15)
    expect(image_list).not_to be(result)
    expect(image_list2).not_to be(result)
    expect(result.cur_image).to be(cur)

    expect { image_list + [2] }.to raise_error(ArgumentError)
  end
end

RSpec.describe Magick::ImageList, '#&' do
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

    result = image_list & image_list2
    expect(result).to be_instance_of(described_class)
    expect(image_list).not_to be(result)
    expect(image_list2).not_to be(result)
    expect(result.length).to eq(5)
    expect(result.scene).to eq(2)
    expect(result.cur_image).to be(cur)

    # current scene not in the result, set result scene to last image in result
    image_list.scene = 2

    result = image_list & image_list2
    expect(result).to be_instance_of(described_class)
    expect(result.scene).to eq(4)

    expect { image_list & 2 }.to raise_error(ArgumentError)
  end
end

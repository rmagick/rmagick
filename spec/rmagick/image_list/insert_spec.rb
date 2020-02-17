RSpec.describe Magick::ImageList, '#insert' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    image_list.scene = 7
    cur = image_list.cur_image
    expect(image_list.insert(1, image_list[2])).to be_instance_of(described_class)
    expect(image_list.cur_image).to be(cur)
    image_list.insert(1, image_list[2], image_list[3], image_list[4])
    expect(image_list.cur_image).to be(cur)

    expect { image_list.insert(0, 'x') }.to raise_error(ArgumentError)
    expect { image_list.insert(0, 'x', 'y') }.to raise_error(ArgumentError)
  end
end

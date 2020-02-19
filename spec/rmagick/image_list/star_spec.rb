RSpec.describe Magick::ImageList, '#*' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    image_list.scene = 7
    cur = image_list.cur_image

    result = image_list * 2
    expect(result).to be_instance_of(described_class)
    expect(result.length).to eq(20)
    expect(image_list).not_to be(result)
    expect(result.cur_image).to be(cur)

    expect { image_list * 'x' }.to raise_error(ArgumentError)
  end
end

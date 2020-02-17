RSpec.describe Magick::ImageList, '#*' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    list.scene = 7
    cur = list.cur_image

    res = list * 2
    expect(res).to be_instance_of(described_class)
    expect(res.length).to eq(20)
    expect(list).not_to be(res)
    expect(res.cur_image).to be(cur)

    expect { list * 'x' }.to raise_error(ArgumentError)
  end
end

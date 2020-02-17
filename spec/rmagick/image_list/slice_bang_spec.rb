RSpec.describe Magick::ImageList, '#slice!' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    list.scene = 7

    image0 = list[0]
    image = list.slice!(0)
    expect(image).to be(image0)
    expect(list.length).to eq(9)
    expect(list.scene).to eq(6)

    cur = list.cur_image
    image = list.slice!(6)
    expect(image).to be(cur)
    expect(list.length).to eq(8)
    expect(list.scene).to eq(7)
    expect { list.slice!(-1) }.not_to raise_error
    expect { list.slice!(0, 1) }.not_to raise_error
    expect { list.slice!(0..2) }.not_to raise_error
    expect { list.slice!(20) }.not_to raise_error
  end
end

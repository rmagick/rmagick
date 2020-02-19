RSpec.describe Magick::ImageList, '#slice!' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    image_list.scene = 7

    image0 = image_list[0]
    image = image_list.slice!(0)
    expect(image).to be(image0)
    expect(image_list.length).to eq(9)
    expect(image_list.scene).to eq(6)

    cur = image_list.cur_image
    image = image_list.slice!(6)
    expect(image).to be(cur)
    expect(image_list.length).to eq(8)
    expect(image_list.scene).to eq(7)
    expect { image_list.slice!(-1) }.not_to raise_error
    expect { image_list.slice!(0, 1) }.not_to raise_error
    expect { image_list.slice!(0..2) }.not_to raise_error
    expect { image_list.slice!(20) }.not_to raise_error
  end
end

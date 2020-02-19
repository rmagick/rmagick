RSpec.describe Magick::ImageList, '#uniq!' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    expect(image_list.uniq!).to be(nil)

    image_list[1] = image_list[0]
    image_list.scene = 7
    cur = image_list.cur_image
    image_list2 = image_list
    image_list.uniq!
    expect(image_list).to be(image_list2)
    expect(image_list.cur_image).to be(cur)
    expect(image_list.scene).to eq(6)
    image_list[5] = image_list[6]
    image_list.uniq!
    expect(image_list.cur_image).to be(cur)
    expect(image_list.scene).to eq(5)
  end
end

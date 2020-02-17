RSpec.describe Magick::ImageList, '#pop' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    image_list.scene = 8
    cur = image_list.cur_image
    last = image_list[-1]

    expect(image_list.pop).to be(last)
    expect(image_list.cur_image).to be(cur)

    expect(image_list.pop).to be(cur)
    expect(image_list.cur_image).to be(image_list[-1])
  end
end

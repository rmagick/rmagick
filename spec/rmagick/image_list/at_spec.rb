RSpec.describe Magick::ImageList, '#at' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    cur = image_list.cur_image
    image = image_list.at(7)
    expect(image_list[7]).to be(image)
    expect(image_list.cur_image).to be(cur)

    image = image_list.at(10)
    expect(image).to be(nil)
    expect(image_list.cur_image).to be(cur)

    image = image_list.at(-1)
    expect(image_list[9]).to be(image)
    expect(image_list.cur_image).to be(cur)
  end
end

RSpec.describe Magick::ImageList, '#at' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    cur = list.cur_image
    image = list.at(7)
    expect(list[7]).to be(image)
    expect(list.cur_image).to be(cur)

    image = list.at(10)
    expect(image).to be(nil)
    expect(list.cur_image).to be(cur)

    image = list.at(-1)
    expect(list[9]).to be(image)
    expect(list.cur_image).to be(cur)
  end
end

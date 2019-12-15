RSpec.describe Magick::ImageList, '#concat' do
  it 'allows appending identical instances more than once' do
    img = Magick::Image.new(1, 1)
    img2 = Magick::Image.new(3, 3)
    list = described_class.new

    list.concat([img, img2, img, img2, img])

    res = list.append(false)
    expect(res.columns).to eq(9)
    expect(res.rows).to eq(3)
  end
end

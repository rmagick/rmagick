RSpec.describe Magick::ImageList, '#<<' do
  it 'allows appending identical instances more than once' do
    img = Magick::Image.new(1, 1)
    list = described_class.new

    list << img << img

    res = list.append(false)
    expect(res.columns).to eq(2)
    expect(res.rows).to eq(1)
  end
end

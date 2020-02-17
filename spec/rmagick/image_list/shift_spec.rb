RSpec.describe Magick::ImageList, '#shift' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    list.scene = 0
    res = list[0]
    img = list.shift
    expect(img).to be(res)
    expect(list.scene).to eq(8)

    res = list[0]
    img = list.shift
    expect(img).to be(res)
    expect(list.scene).to eq(7)
  end
end

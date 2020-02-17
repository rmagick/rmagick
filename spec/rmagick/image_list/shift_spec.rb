RSpec.describe Magick::ImageList, '#shift' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    list.scene = 0
    result = list[0]
    image = list.shift
    expect(image).to be(result)
    expect(list.scene).to eq(8)

    result = list[0]
    image = list.shift
    expect(image).to be(result)
    expect(list.scene).to eq(7)
  end
end

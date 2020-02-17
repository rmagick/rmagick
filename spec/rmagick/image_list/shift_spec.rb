RSpec.describe Magick::ImageList, '#shift' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    image_list.scene = 0
    result = image_list[0]
    image = image_list.shift
    expect(image).to be(result)
    expect(image_list.scene).to eq(8)

    result = image_list[0]
    image = image_list.shift
    expect(image).to be(result)
    expect(image_list.scene).to eq(7)
  end
end

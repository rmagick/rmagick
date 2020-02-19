RSpec.describe Magick::ImageList, '#unshift' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    image = image_list[9]
    image_list.scene = 7
    image_list.unshift(image)
    expect(image_list.scene).to eq(0)
    expect { image_list.unshift(2) }.to raise_error(ArgumentError)
    expect { image_list.unshift([1, 2]) }.to raise_error(ArgumentError)
  end
end

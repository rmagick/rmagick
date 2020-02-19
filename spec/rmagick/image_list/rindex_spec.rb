RSpec.describe Magick::ImageList, '#rindex' do
  it 'works' do
    image_list = described_class.new(*FILES[0..9])

    image = image_list.last
    n = nil
    expect { n = image_list.rindex(image) }.not_to raise_error
    expect(n).to eq(9)
  end
end

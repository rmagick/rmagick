RSpec.describe Magick::ImageList, '#rindex' do
  it 'works' do
    list = described_class.new(*FILES[0..9])

    image = list.last
    n = nil
    expect { n = list.rindex(image) }.not_to raise_error
    expect(n).to eq(9)
  end
end

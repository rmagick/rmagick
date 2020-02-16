RSpec.describe Magick::Pixel, '#intensity' do
  it 'works' do
    pixel = described_class.from_color('brown')

    expect(pixel.intensity).to be_kind_of(Integer)
  end
end

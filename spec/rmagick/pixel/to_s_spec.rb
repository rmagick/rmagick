RSpec.describe Magick::Pixel, '#to_s' do
  it 'works' do
    pixel = described_class.from_color('brown')

    expect(pixel.to_s).to match(/red=\d+, green=\d+, blue=\d+, alpha=\d+/)
  end
end

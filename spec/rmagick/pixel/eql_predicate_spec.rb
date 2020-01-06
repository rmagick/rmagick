RSpec.describe Magick::Pixel, '#eql?' do
  it 'works' do
    pixel = described_class.from_color('brown')

    pixel2 = pixel
    expect(pixel.eql?(pixel2)).to be(true)
    pixel2 = described_class.new
    expect(pixel.eql?(pixel2)).to be(false)
  end
end

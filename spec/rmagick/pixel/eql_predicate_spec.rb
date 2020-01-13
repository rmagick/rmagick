RSpec.describe Magick::Pixel, '#eql?' do
  before do
    @pixel = described_class.from_color('brown')
  end

  it 'works' do
    pixel2 = @pixel
    expect(@pixel.eql?(pixel2)).to be(true)
    pixel2 = described_class.new
    expect(@pixel.eql?(pixel2)).to be(false)
  end
end

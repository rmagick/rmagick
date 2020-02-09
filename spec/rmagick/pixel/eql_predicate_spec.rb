RSpec.describe Magick::Pixel, '#eql?' do
  before do
    @pixel = described_class.from_color('brown')
  end

  it 'works' do
    p = @pixel
    expect(@pixel.eql?(p)).to be(true)
    p = described_class.new
    expect(@pixel.eql?(p)).to be(false)
  end
end

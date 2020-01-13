RSpec.describe Magick::Pixel, '#eql?' do
  before do
    @pixel = Magick::Pixel.from_color('brown')
  end

  it 'works' do
    p = @pixel
    expect(@pixel.eql?(p)).to be(true)
    p = Magick::Pixel.new
    expect(@pixel.eql?(p)).to be(false)
  end
end

RSpec.describe Magick::Pixel, '#===' do
  before do
    @pixel = Magick::Pixel.from_color('brown')
  end

  it 'works' do
    pixel = Magick::Pixel.from_color('brown')
    expect(@pixel === pixel).to be(true)
    expect(@pixel === 'red').to be(false)

    pixel = Magick::Pixel.from_color('red')
    expect(@pixel === pixel).to be(false)
  end
end

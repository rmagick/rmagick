RSpec.describe Magick::Pixel, '#===' do
  before do
    @pixel = described_class.from_color('brown')
  end

  it 'works' do
    pixel = described_class.from_color('brown')
    expect(@pixel === pixel).to be(true)
    expect(@pixel === 'red').to be(false)

    pixel = described_class.from_color('red')
    expect(@pixel === pixel).to be(false)
  end
end

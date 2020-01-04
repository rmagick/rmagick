RSpec.describe Magick::Pixel, '#intensity' do
  before do
    @pixel = Magick::Pixel.from_color('brown')
  end

  it 'works' do
    expect(@pixel.intensity).to be_kind_of(Integer)
  end
end

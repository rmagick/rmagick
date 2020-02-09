RSpec.describe Magick::Pixel, '#to_s' do
  before do
    @pixel = described_class.from_color('brown')
  end

  it 'works' do
    expect(@pixel.to_s).to match(/red=\d+, green=\d+, blue=\d+, alpha=\d+/)
  end
end

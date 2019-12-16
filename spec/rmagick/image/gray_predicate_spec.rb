RSpec.describe Magick::Image, '#gray?' do
  before { @img = Magick::Image.new(20, 20) }

  it 'works' do
    gray = Magick::Image.new(20, 20) { self.background_color = 'gray50' }
    expect(gray.gray?).to be(true)
    red = Magick::Image.new(20, 20) { self.background_color = 'red' }
    expect(red.gray?).to be(false)
  end
end

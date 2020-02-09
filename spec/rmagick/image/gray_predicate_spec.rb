RSpec.describe Magick::Image, '#gray?' do
  before { @img = described_class.new(20, 20) }

  it 'works' do
    gray = described_class.new(20, 20) { self.background_color = 'gray50' }
    expect(gray.gray?).to be(true)
    red = described_class.new(20, 20) { self.background_color = 'red' }
    expect(red.gray?).to be(false)
  end
end

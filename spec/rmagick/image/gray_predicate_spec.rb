RSpec.describe Magick::Image, '#gray?' do
  it 'works' do
    gray = described_class.new(20, 20) { |e| e.background_color = 'gray50' }
    expect(gray.gray?).to be(true)
    red = described_class.new(20, 20) { |e| e.background_color = 'red' }
    expect(red.gray?).to be(false)
  end
end

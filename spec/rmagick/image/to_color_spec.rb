RSpec.describe Magick::Image, '#to_color' do
  it 'works' do
    image = described_class.new(20, 20)
    red = Magick::Pixel.new(Magick::QuantumRange)

    result = image.to_color(red)
    expect(result).to eq('red')
  end
end

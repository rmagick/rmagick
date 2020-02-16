RSpec.describe Magick::Image, '#to_color' do
  it 'works' do
    img = described_class.new(20, 20)
    red = Magick::Pixel.new(Magick::QuantumRange)

    expect do
      res = img.to_color(red)
      expect(res).to eq('red')
    end.not_to raise_error
  end
end

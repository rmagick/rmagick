RSpec.describe Magick::Image::Info, '#border_color' do
  it 'works' do
    info = described_class.new

    expect { info.border_color = 'red' }.not_to raise_error
    red = Magick::Pixel.new(Magick::QuantumRange)
    expect { info.border_color = red }.not_to raise_error
    expect(info.border_color).to eq('red')
    image = Magick::Image.new(20, 20) { self.border_color = 'red' }
    expect(image.border_color).to eq('red')
  end
end

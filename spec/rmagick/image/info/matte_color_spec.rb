RSpec.describe Magick::Image::Info, '#matte_color' do
  it 'works' do
    info = described_class.new

    expect { info.matte_color = 'red' }.not_to raise_error
    red = Magick::Pixel.new(Magick::QuantumRange)
    expect { info.matte_color = red }.not_to raise_error
    expect(info.matte_color).to eq('red')
    image = Magick::Image.new(20, 20) { self.matte_color = 'red' }
    expect(image.matte_color).to eq('red')
    expect { info.matte_color = nil }.to raise_error(TypeError)
  end
end

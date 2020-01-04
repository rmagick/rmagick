RSpec.describe Magick::Image::Info, '#matte_color' do
  before do
    @info = Magick::Image::Info.new
  end

  it 'works' do
    expect { @info.matte_color = 'red' }.not_to raise_error
    red = Magick::Pixel.new(Magick::QuantumRange)
    expect { @info.matte_color = red }.not_to raise_error
    expect(@info.matte_color).to eq('red')
    img = Magick::Image.new(20, 20) { self.matte_color = 'red' }
    expect(img.matte_color).to eq('red')
    expect { @info.matte_color = nil }.to raise_error(TypeError)
  end
end

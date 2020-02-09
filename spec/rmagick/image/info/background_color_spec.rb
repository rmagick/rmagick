RSpec.describe Magick::Image::Info, '#background_color' do
  before do
    @info = described_class.new
  end

  it 'works' do
    expect { @info.background_color = 'red' }.not_to raise_error
    red = Magick::Pixel.new(Magick::QuantumRange)
    expect { @info.background_color = red }.not_to raise_error
    expect(@info.background_color).to eq('red')
    img = Magick::Image.new(20, 20) { self.background_color = 'red' }
    expect(img.background_color).to eq('red')
  end
end

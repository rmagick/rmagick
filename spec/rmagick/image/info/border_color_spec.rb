RSpec.describe Magick::Image::Info, '#border_color' do
  before do
    @info = Magick::Image::Info.new
  end

  it 'works' do
    expect { @info.border_color = 'red' }.not_to raise_error
    red = Magick::Pixel.new(Magick::QuantumRange)
    expect { @info.border_color = red }.not_to raise_error
    expect(@info.border_color).to eq('red')
    img = Magick::Image.new(20, 20) { self.border_color = 'red' }
    expect(img.border_color).to eq('red')
  end
end

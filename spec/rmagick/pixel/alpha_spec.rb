RSpec.describe Magick::Pixel, '#alpha' do
  before do
    @pixel = Magick::Pixel.from_color('brown')
  end

  it 'works' do
    expect { @pixel.alpha = 123 }.not_to raise_error
    expect(@pixel.alpha).to eq(123)
    expect { @pixel.alpha = 255.25 }.not_to raise_error
    expect(@pixel.alpha).to eq(255)
    expect { @pixel.alpha = 'x' }.to raise_error(TypeError)
  end
end

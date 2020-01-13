RSpec.describe Magick::Pixel, '#cyan' do
  before do
    @pixel = Magick::Pixel.from_color('brown')
  end

  it 'works' do
    expect { @pixel.cyan = 123 }.not_to raise_error
    expect(@pixel.cyan).to eq(123)
    expect { @pixel.cyan = 255.25 }.not_to raise_error
    expect(@pixel.cyan).to eq(255)
    expect { @pixel.cyan = 'x' }.to raise_error(TypeError)
  end
end

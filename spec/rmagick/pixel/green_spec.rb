RSpec.describe Magick::Pixel, '#green' do
  before do
    @pixel = Magick::Pixel.from_color('brown')
  end

  it 'works' do
    expect { @pixel.green = 123 }.not_to raise_error
    expect(@pixel.green).to eq(123)
    expect { @pixel.green = 255.25 }.not_to raise_error
    expect(@pixel.green).to eq(255)
    expect { @pixel.green = 'x' }.to raise_error(TypeError)
  end
end

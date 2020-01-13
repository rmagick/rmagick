RSpec.describe Magick::Pixel, '#blue' do
  before do
    @pixel = Magick::Pixel.from_color('brown')
  end

  it 'works' do
    expect { @pixel.blue = 123 }.not_to raise_error
    expect(@pixel.blue).to eq(123)
    expect { @pixel.blue = 255.25 }.not_to raise_error
    expect(@pixel.blue).to eq(255)
    expect { @pixel.blue = 'x' }.to raise_error(TypeError)
  end
end

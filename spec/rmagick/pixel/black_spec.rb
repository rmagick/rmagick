RSpec.describe Magick::Pixel, '#black' do
  before do
    @pixel = described_class.from_color('brown')
  end

  it 'works' do
    expect { @pixel.black = 123 }.not_to raise_error
    expect(@pixel.black).to eq(123)
    expect { @pixel.black = 255.25 }.not_to raise_error
    expect(@pixel.black).to eq(255)
    expect { @pixel.black = 'x' }.to raise_error(TypeError)
  end
end

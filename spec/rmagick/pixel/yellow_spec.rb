RSpec.describe Magick::Pixel, '#yellow' do
  before do
    @pixel = described_class.from_color('brown')
  end

  it 'works' do
    expect { @pixel.yellow = 123 }.not_to raise_error
    expect(@pixel.yellow).to eq(123)
    expect { @pixel.yellow = 255.25 }.not_to raise_error
    expect(@pixel.yellow).to eq(255)
    expect { @pixel.yellow = 'x' }.to raise_error(TypeError)
  end
end

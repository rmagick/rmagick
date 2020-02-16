RSpec.describe Magick::Pixel, '#alpha' do
  it 'works' do
    pixel = described_class.from_color('brown')

    expect { pixel.alpha = 123 }.not_to raise_error
    expect(pixel.alpha).to eq(123)
    expect { pixel.alpha = 255.25 }.not_to raise_error
    expect(pixel.alpha).to eq(255)
    expect { pixel.alpha = 'x' }.to raise_error(TypeError)
  end
end

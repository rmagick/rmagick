RSpec.describe Magick::Pixel, '#magenta' do
  it 'works' do
    pixel = described_class.from_color('brown')

    expect { pixel.magenta = 123 }.not_to raise_error
    expect(pixel.magenta).to eq(123)
    expect { pixel.magenta = 255.25 }.not_to raise_error
    expect(pixel.magenta).to eq(255)
    expect { pixel.magenta = 'x' }.to raise_error(TypeError)
  end
end

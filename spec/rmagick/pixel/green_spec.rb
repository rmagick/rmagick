RSpec.describe Magick::Pixel, '#green' do
  it 'works' do
    pixel = described_class.from_color('brown')

    expect { pixel.green = 123 }.not_to raise_error
    expect(pixel.green).to eq(123)
    expect { pixel.green = 255.25 }.not_to raise_error
    expect(pixel.green).to eq(255)
    expect { pixel.green = 'x' }.to raise_error(TypeError)
  end
end

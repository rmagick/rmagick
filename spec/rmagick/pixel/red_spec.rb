RSpec.describe Magick::Pixel, '#red' do
  it 'works' do
    pixel = described_class.from_color('brown')

    expect { pixel.red = 123 }.not_to raise_error
    expect(pixel.red).to eq(123)
    expect { pixel.red = 255.25 }.not_to raise_error
    expect(pixel.red).to eq(255)
    expect { pixel.red = 'x' }.to raise_error(TypeError)
  end
end

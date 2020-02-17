RSpec.describe Magick::Image, '#tint' do
  it 'works' do
    image = described_class.new(20, 20)

    expect do
      pixels = image.get_pixels(0, 0, 1, 1)
      image.tint(pixels[0], 1.0)
    end.not_to raise_error
    expect { image.tint('red', 1.0) }.not_to raise_error
    expect { image.tint('red', 1.0, 1.0) }.not_to raise_error
    expect { image.tint('red', 1.0, 1.0, 1.0) }.not_to raise_error
    expect { image.tint('red', 1.0, 1.0, 1.0, 1.0) }.not_to raise_error
    expect { image.tint }.to raise_error(ArgumentError)
    expect { image.tint('red') }.to raise_error(ArgumentError)
    expect { image.tint('red', 1.0, 1.0, 1.0, 1.0, 1.0) }.to raise_error(ArgumentError)
    expect { image.tint('x', 1.0) }.to raise_error(ArgumentError)
    expect { image.tint('red', -1.0, 1.0, 1.0, 1.0) }.to raise_error(ArgumentError)
    expect { image.tint('red', 1.0, -1.0, 1.0, 1.0) }.to raise_error(ArgumentError)
    expect { image.tint('red', 1.0, 1.0, -1.0, 1.0) }.to raise_error(ArgumentError)
    expect { image.tint('red', 1.0, 1.0, 1.0, -1.0) }.to raise_error(ArgumentError)
    expect { image.tint(1.0, 1.0) }.to raise_error(TypeError)
    expect { image.tint('red', 'green') }.to raise_error(TypeError)
    expect { image.tint('red', 1.0, 'green') }.to raise_error(TypeError)
    expect { image.tint('red', 1.0, 1.0, 'green') }.to raise_error(TypeError)
    expect { image.tint('red', 1.0, 1.0, 1.0, 'green') }.to raise_error(TypeError)
  end
end

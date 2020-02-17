RSpec.describe Magick::Image, '#frame' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.frame
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(image)

    expect { image.frame(50) }.not_to raise_error
    expect { image.frame(50, 50) }.not_to raise_error
    expect { image.frame(50, 50, 25) }.not_to raise_error
    expect { image.frame(50, 50, 25, 25) }.not_to raise_error
    expect { image.frame(50, 50, 25, 25, 6) }.not_to raise_error
    expect { image.frame(50, 50, 25, 25, 6, 6) }.not_to raise_error
    expect { image.frame(50, 50, 25, 25, 6, 6, 'red') }.not_to raise_error
    red = Magick::Pixel.new(Magick::QuantumRange)
    expect { image.frame(50, 50, 25, 25, 6, 6, red) }.not_to raise_error
    expect { image.frame(50, 50, 25, 25, 6, 6, 2) }.to raise_error(TypeError)
    expect { image.frame(50, 50, 25, 25, 6, 6, red, 2) }.to raise_error(ArgumentError)
  end
end

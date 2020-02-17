RSpec.describe Magick::Image, '#splice' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.splice(0, 0, 2, 2)
    expect(res).to be_instance_of(described_class)

    expect { image.splice(0, 0, 2, 2, 'red') }.not_to raise_error
    red = Magick::Pixel.new(Magick::QuantumRange)
    expect { image.splice(0, 0, 2, 2, red) }.not_to raise_error
    expect { image.splice(0, 0, 2, 2, red, 'x') }.to raise_error(ArgumentError)
    expect { image.splice([], 0, 2, 2, red) }.to raise_error(TypeError)
    expect { image.splice(0, 'x', 2, 2, red) }.to raise_error(TypeError)
    expect { image.splice(0, 0, 'x', 2, red) }.to raise_error(TypeError)
    expect { image.splice(0, 0, 2, [], red) }.to raise_error(TypeError)
    expect { image.splice(0, 0, 2, 2, /m/) }.to raise_error(TypeError)
  end
end

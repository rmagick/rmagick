RSpec.describe Magick::Image, "#colorize" do
  it "works" do
    image = described_class.new(20, 20)

    res = image.colorize(0.25, 0.25, 0.25, 'red')
    expect(res).to be_instance_of(described_class)

    expect { image.colorize(0.25, 0.25, 0.25, 0.25, 'red') }.not_to raise_error
    pixel = Magick::Pixel.new(Magick::QuantumRange)
    expect { image.colorize(0.25, 0.25, 0.25, pixel) }.not_to raise_error
    expect { image.colorize(0.25, 0.25, 0.25, 0.25, pixel) }.not_to raise_error
    expect { image.colorize }.to raise_error(ArgumentError)
    expect { image.colorize(0.25) }.to raise_error(ArgumentError)
    expect { image.colorize(0.25, 0.25) }.to raise_error(ArgumentError)
    expect { image.colorize(0.25, 0.25, 0.25) }.to raise_error(ArgumentError)
    expect { image.colorize(0.25, 0.25, 0.25, 'X') }.to raise_error(ArgumentError)
    # last argument must be a color name or pixel
    expect { image.colorize(0.25, 0.25, 0.25, 0.25) }.to raise_error(TypeError)
    expect { image.colorize(0.25, 0.25, 0.25, 0.25, 'X') }.to raise_error(ArgumentError)
    expect { image.colorize(0.25, 0.25, 0.25, 0.25, [2]) }.to raise_error(TypeError)
  end
end

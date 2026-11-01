# frozen_string_literal: true

RSpec.describe Magick::Image, '#frame' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.frame
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

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

  it 'raises an error when the offset of the image and the bevels do not fit in the frame' do
    image = described_class.new(20, 20)
    long_max = [0].pack('l!').bytesize < 8 ? (2**31) - 1 : (2**63) - 1

    expect { image.frame(30, 30, 3, 4, 2, 2) }.to raise_error(ArgumentError, /invalid frame geometry/)
    expect { image.frame(30, 30, 4, 3, 2, 2) }.to raise_error(ArgumentError, /invalid frame geometry/)
    expect { image.frame(10, 10, 5, 5) }.to raise_error(ArgumentError, /invalid frame geometry/)
    expect { image.frame(10, 10, -5, -5) }.to raise_error(ArgumentError, /invalid frame geometry/)
    expect { image.frame(10, 10, 17, 4, 2, 2) }.to raise_error(ArgumentError, /invalid frame geometry/)
    expect { image.frame(10, 10, 4, 17, 2, 2) }.to raise_error(ArgumentError, /invalid frame geometry/)
    expect { image.frame(10, 42, long_max, 42, 0, 42) }.to raise_error(ArgumentError, /invalid frame geometry/)
    expect { image.frame(30, 30, 12, 12, -6, 6) }.to raise_error(ArgumentError, /invalid frame geometry/)
    expect(image.frame(10, 10, 16, 16, 2, 2).columns).to eq(40)
    expect(image.frame(10, 10, 4, 4, 2, 2).columns).to eq(40)
  end

  it 'raises an error when the frame size overflows', if: [0].pack('l!').bytesize == 8 do
    image = described_class.new(4, 4)

    expect { image.frame((2**63) - 1, 4, (2**63) - 1, 4, 2, 2) }.to raise_error(ArgumentError, /invalid frame geometry/)
    expect { image.frame(4, (2**63) - 1, 4, (2**63) - 1, 2, 2) }.to raise_error(ArgumentError, /invalid frame geometry/)
  end

  it 'does not change the matte color of the image' do
    image = described_class.new(4, 4) { |info| info.depth = 16 }
    image.freeze

    result = image.frame(6, 6, 2, 2, 0, 0, 'red')

    expect(image.matte_color).to eq('#BDBDBDBDBDBDFFFF')
    expect(result.matte_color).to eq('#FFFF00000000FFFF')
    expect(result.to_color(result.pixel_color(0, 0))).to eq('red')
  end
end

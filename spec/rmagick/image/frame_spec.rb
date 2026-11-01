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

  it 'does not change the matte color of the image' do
    image = described_class.new(4, 4) { |info| info.depth = 16 }
    image.freeze

    result = image.frame(6, 6, 2, 2, 0, 0, 'red')

    expect(image.matte_color).to eq('#BDBDBDBDBDBDFFFF')
    expect(result.matte_color).to eq('#FFFF00000000FFFF')
    expect(result.to_color(result.pixel_color(0, 0))).to eq('red')
  end
end

# frozen_string_literal: true

RSpec.describe Magick::Image, '#background_color' do
  it 'works' do
    image = described_class.new(100, 100) { |info| info.depth = 16 }

    expect { image.background_color }.not_to raise_error
    expect(image.background_color).to eq('#FFFFFFFFFFFFFFFF')
    expect { image.background_color = '#dfdfdf' }.not_to raise_error
    # expect(image.background_color).to eq("rgb(223,223,223)")
    background_color = image.background_color
    expect(background_color).to eq('#DFDFDFDFDFDFFFFF')
    expect { image.background_color = Magick::Pixel.new(Magick::QuantumRange, Magick::QuantumRange / 2.0, Magick::QuantumRange / 2.0) }.not_to raise_error
    # expect(image.background_color).to eq("rgb(100%,49.9992%,49.9992%)")
    background_color = image.background_color
    expect(background_color).to eq('#FFFF7FFF7FFFFFFF')
    expect { image.background_color = 2 }.to raise_error(TypeError)

    image = described_class.new(100, 100) { |info| info.depth = 8 }

    expect { image.background_color }.not_to raise_error
    expect(image.background_color).to eq('#FFFFFFFF')
  end
end

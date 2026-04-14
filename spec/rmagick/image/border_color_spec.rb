# frozen_string_literal: true

RSpec.describe Magick::Image, '#border_color' do
  it 'works' do
    image = described_class.new(100, 100) { |info| info.depth = 16 }

    expect { image.border_color }.not_to raise_error
    # expect(image.border_color).to eq("rgb(223,223,223)")
    border_color = image.border_color
    expect(border_color).to eq('#DFDFDFDFDFDFFFFF')
    expect { image.border_color = 'red' }.not_to raise_error
    expect(image.border_color).to eq('#FFFF00000000FFFF')
    expect { image.border_color = Magick::Pixel.new(Magick::QuantumRange, Magick::QuantumRange / 2, Magick::QuantumRange / 2) }.not_to raise_error
    # expect(image.border_color).to eq("rgb(100%,49.9992%,49.9992%)")
    border_color = image.border_color
    expect(border_color).to eq('#FFFF7FFF7FFFFFFF')
    expect { image.border_color = 2 }.to raise_error(TypeError)

    image = described_class.new(100, 100) { |info| info.depth = 8 }
    border_color = image.border_color
    expect(border_color).to eq('#DFDFDFFF')
  end
end

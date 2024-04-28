RSpec.describe Magick::Image, '#background_color' do
  it 'works' do
    image = described_class.new(100, 100) { |info| info.depth = 16 }

    expect { image.background_color }.not_to raise_error
    expected = value_by_version(
      "6.8": "#FFFFFFFFFFFF",
      "6.9": "#FFFFFFFFFFFFFFFF",
      "7.0": "#FFFFFFFFFFFFFFFF",
      "7.1": "#FFFFFFFFFFFFFFFF"
    )
    expect(image.background_color).to eq(expected)
    expect { image.background_color = '#dfdfdf' }.not_to raise_error
    # expect(image.background_color).to eq("rgb(223,223,223)")
    background_color = image.background_color
    expected = value_by_version(
      "6.8": "#DFDFDFDFDFDF",
      "6.9": "#DFDFDFDFDFDFFFFF",
      "7.0": "#DFDFDFDFDFDFFFFF",
      "7.1": "#DFDFDFDFDFDFFFFF"
    )
    expect(background_color).to eq(expected)
    expect { image.background_color = Magick::Pixel.new(Magick::QuantumRange, Magick::QuantumRange / 2.0, Magick::QuantumRange / 2.0) }.not_to raise_error
    # expect(image.background_color).to eq("rgb(100%,49.9992%,49.9992%)")
    background_color = image.background_color
    expected = value_by_version(
      "6.8": "#FFFF7FFF7FFF",
      "6.9": "#FFFF7FFF7FFFFFFF",
      "7.0": "#FFFF7FFF7FFFFFFF",
      "7.1": "#FFFF7FFF7FFFFFFF"
    )
    expect(background_color).to eq(expected)
    expect { image.background_color = 2 }.to raise_error(TypeError)

    image = described_class.new(100, 100) { |info| info.depth = 8 }

    expect { image.background_color }.not_to raise_error
    expected = value_by_version(
      "6.8": "#FFFFFF",
      "6.9": "#FFFFFFFF",
      "7.0": "#FFFFFFFF",
      "7.1": "#FFFFFFFF"
    )
    expect(image.background_color).to eq(expected)
  end
end

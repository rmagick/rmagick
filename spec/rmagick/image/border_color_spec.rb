RSpec.describe Magick::Image, '#border_color' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.border_color }.not_to raise_error
    # expect(image.border_color).to eq("rgb(223,223,223)")
    border_color = image.border_color
    expected = value_by_version(
      "6.8": "#DFDFDFDFDFDF",
      "6.9": "#DFDFDFDFDFDFFFFF",
      "7.0": "#DFDFDFDFDFDFFFFF",
      "7.1": "#DFDFDFDFDFDFFFFF"
    )
    expect(border_color).to eq(expected)
    expect { image.border_color = 'red' }.not_to raise_error
    expected = value_by_version(
      "6.8": "#FFFF00000000",
      "6.9": "#FFFF00000000FFFF",
      "7.0": "#FFFF00000000FFFF",
      "7.1": "#FFFF00000000FFFF"
    )
    expect(image.border_color).to eq(expected)
    expect { image.border_color = Magick::Pixel.new(Magick::QuantumRange, Magick::QuantumRange / 2, Magick::QuantumRange / 2) }.not_to raise_error
    # expect(image.border_color).to eq("rgb(100%,49.9992%,49.9992%)")
    border_color = image.border_color
    expected = value_by_version(
      "6.8": "#FFFF7FFF7FFF",
      "6.9": "#FFFF7FFF7FFFFFFF",
      "7.0": "#FFFF7FFF7FFFFFFF",
      "7.1": "#FFFF7FFF7FFFFFFF"
    )
    expect(border_color).to eq(expected)
    expect { image.border_color = 2 }.to raise_error(TypeError)
  end
end

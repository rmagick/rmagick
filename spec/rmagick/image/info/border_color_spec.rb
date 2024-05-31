# frozen_string_literal: true

RSpec.describe Magick::Image::Info, '#border_color' do
  it 'works' do
    info = described_class.new
    info.depth = 16

    expect { info.border_color = 'red' }.not_to raise_error
    red = Magick::Pixel.new(Magick::QuantumRange)
    expect { info.border_color = red }.not_to raise_error
    expected = value_by_version(
      "6.8": "#FFFF00000000",
      "6.9": "#FFFF00000000FFFF",
      "7.0": "#FFFF00000000FFFF",
      "7.1": "#FFFF00000000FFFF"
    )
    expect(info.border_color).to eq(expected)
    image = Magick::Image.new(20, 20) { |options| options.border_color = 'red' }
    expect(image.border_color).to eq(expected)

    info = described_class.new
    info.depth = 8

    expect { info.border_color = 'red' }.not_to raise_error
    expected = value_by_version(
      "6.8": "#FF0000",
      "6.9": "#FF0000FF",
      "7.0": "#FF0000FF",
      "7.1": "#FF0000FF"
    )
    expect(info.border_color).to eq(expected)
  end
end

# frozen_string_literal: true

RSpec.describe Magick::Image::Info, '#border_color' do
  it 'works' do
    info = described_class.new
    info.depth = 16

    expect { info.border_color = 'red' }.not_to raise_error
    red = Magick::Pixel.new(Magick::QuantumRange)
    expect { info.border_color = red }.not_to raise_error
    expect(info.border_color).to eq('#FFFF00000000FFFF')
    image = Magick::Image.new(20, 20) { |options| options.border_color = 'red' }
    expect(image.border_color).to eq('#FFFF00000000FFFF')

    info = described_class.new
    info.depth = 8

    expect { info.border_color = 'red' }.not_to raise_error
    expect(info.border_color).to eq('#FF0000FF')
  end
end

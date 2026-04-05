# frozen_string_literal: true

RSpec.describe Magick::Image::Info, '#background_color' do
  it 'works' do
    info = described_class.new
    info.depth = 16

    expect { info.background_color = 'red' }.not_to raise_error
    red = Magick::Pixel.new(Magick::QuantumRange)
    expect { info.background_color = red }.not_to raise_error
    expect(info.background_color).to eq('#FFFF00000000FFFF')
    image = Magick::Image.new(20, 20) { |options| options.background_color = 'red' }
    expect(image.background_color).to eq('#FFFF00000000FFFF')

    info = described_class.new
    info.depth = 8

    expect { info.background_color = 'red' }.not_to raise_error
    expect(info.background_color).to eq('#FF0000FF')
  end
end

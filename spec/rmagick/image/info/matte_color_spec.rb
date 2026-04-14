# frozen_string_literal: true

RSpec.describe Magick::Image::Info, '#matte_color' do
  it 'works' do
    info = described_class.new
    info.depth = 16

    expect { info.matte_color = 'red' }.not_to raise_error
    red = Magick::Pixel.new(Magick::QuantumRange)
    expect { info.matte_color = red }.not_to raise_error
    expect(info.matte_color).to eq('#FFFF00000000FFFF')
    image = Magick::Image.new(20, 20) { |options| options.matte_color = 'red' }
    expect(image.matte_color).to eq('#FFFF00000000FFFF')
    expect { info.matte_color = nil }.to raise_error(TypeError)

    info = described_class.new
    info.depth = 8

    expect { info.matte_color = 'red' }.not_to raise_error
    expect(info.matte_color).to eq('#FF0000FF')
  end
end

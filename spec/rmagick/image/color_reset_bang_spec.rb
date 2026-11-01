# frozen_string_literal: true

RSpec.describe Magick::Image, "#color_reset!" do
  it "works" do
    image = described_class.new(20, 20)

    result = image.color_reset!('red')
    expect(result).to be(image)

    pixel = Magick::Pixel.new(Magick::QuantumRange)
    expect { image.color_reset!(pixel) }.not_to raise_error
    expect { image.color_reset!([2]) }.to raise_error(TypeError)
    expect { image.color_reset!('x') }.to raise_error(ArgumentError)
    image.freeze
    expect { image.color_reset!('red') }.to raise_error(FrozenError)
  end

  it 'restores the background color of a CMYK image' do
    image = described_class.new(1, 1) { |info| info.depth = 16 }
    image.colorspace = Magick::CMYKColorspace
    image.background_color = 'blue'

    image.color_reset!('red')

    expect(image.background_color).to eq('#00000000FFFFFFFF')
    image.colorspace = Magick::SRGBColorspace
    expect(image.to_color(image.pixel_color(0, 0))).to eq('red')
  end
end

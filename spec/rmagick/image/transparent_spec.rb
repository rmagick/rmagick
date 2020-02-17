RSpec.describe Magick::Image, '#transparent' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.transparent('white')
    expect(res).to be_instance_of(described_class)

    pixel = Magick::Pixel.new
    expect { image.transparent(pixel) }.not_to raise_error
    expect { image.transparent('white', Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { image.transparent('white', alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { image.transparent('white', wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { image.transparent('white', alpha: Magick::TransparentAlpha, extra: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { image.transparent('white', Magick::TransparentAlpha, 2) }.to raise_error(ArgumentError)
    expect { image.transparent('white', Magick::QuantumRange / 2) }.to raise_error(ArgumentError)
    expect { image.transparent(2) }.to raise_error(TypeError)
  end
end

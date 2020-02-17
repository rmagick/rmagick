RSpec.describe Magick::Image, '#transparent_chroma' do
  it 'works' do
    image = described_class.new(20, 20)

    expect(image.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange))).to be_instance_of(described_class)
    expect { image.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange)) }.not_to raise_error
    expect { image.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange), Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { image.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange), alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { image.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange), wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { image.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange), Magick::TransparentAlpha, true) }.to raise_error(ArgumentError)
    expect { image.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange), true, alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { image.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange), false, wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { image.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange), false, alpha: Magick::TransparentAlpha, extra: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
  end
end

RSpec.describe Magick::Image, '#transparent_chroma' do
  before do
    @img = Magick::Image.new(20, 20)
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect(@img.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange))).to be_instance_of(Magick::Image)
    expect { @img.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange)) }.not_to raise_error
    expect { @img.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange), Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { @img.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange), alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { @img.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange), wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { @img.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange), Magick::TransparentAlpha, true) }.to raise_error(ArgumentError)
    expect { @img.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange), true, alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { @img.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange), false, wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { @img.transparent_chroma('white', Magick::Pixel.new(Magick::QuantumRange), false, alpha: Magick::TransparentAlpha, extra: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
  end
end

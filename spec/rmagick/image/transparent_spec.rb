RSpec.describe Magick::Image, '#transparent' do
  it 'works' do
    img = described_class.new(20, 20)

    expect do
      res = img.transparent('white')
      expect(res).to be_instance_of(described_class)
    end.not_to raise_error
    pixel = Magick::Pixel.new
    expect { img.transparent(pixel) }.not_to raise_error
    expect { img.transparent('white', Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { img.transparent('white', alpha: Magick::TransparentAlpha) }.not_to raise_error
    expect { img.transparent('white', wrong: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { img.transparent('white', alpha: Magick::TransparentAlpha, extra: Magick::TransparentAlpha) }.to raise_error(ArgumentError)
    expect { img.transparent('white', Magick::TransparentAlpha, 2) }.to raise_error(ArgumentError)
    expect { img.transparent('white', Magick::QuantumRange / 2) }.to raise_error(ArgumentError)
    expect { img.transparent(2) }.to raise_error(TypeError)
  end
end

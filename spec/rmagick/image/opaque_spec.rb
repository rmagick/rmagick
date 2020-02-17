RSpec.describe Magick::Image, '#opaque' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.opaque('white', 'red')
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    red = Magick::Pixel.new(Magick::QuantumRange)
    blue = Magick::Pixel.new(0, 0, Magick::QuantumRange)
    expect { image.opaque(red, blue) }.not_to raise_error
    expect { image.opaque(red, 2) }.to raise_error(TypeError)
    expect { image.opaque(2, blue) }.to raise_error(TypeError)
  end
end

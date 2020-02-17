RSpec.describe Magick::Image, '#opaque' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.opaque('white', 'red')
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(img)

    red = Magick::Pixel.new(Magick::QuantumRange)
    blue = Magick::Pixel.new(0, 0, Magick::QuantumRange)
    expect { img.opaque(red, blue) }.not_to raise_error
    expect { img.opaque(red, 2) }.to raise_error(TypeError)
    expect { img.opaque(2, blue) }.to raise_error(TypeError)
  end
end

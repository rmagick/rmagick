RSpec.describe Magick::Image, '#endian' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.endian }.not_to raise_error
    expect(image.endian).to be_instance_of(Magick::EndianType)
    expect(image.endian).to eq(Magick::UndefinedEndian)
    expect { image.endian = Magick::LSBEndian }.not_to raise_error
    expect(image.endian).to eq(Magick::LSBEndian)
    expect { image.endian = Magick::MSBEndian }.not_to raise_error
    expect { image.endian = 2 }.to raise_error(TypeError)
  end
end

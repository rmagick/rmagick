RSpec.describe Magick::Image, '#compression' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.compression }.not_to raise_error
    expect(image.compression).to be_instance_of(Magick::CompressionType)
    expect(image.compression).to eq(Magick::UndefinedCompression)
    expect { image.compression = Magick::BZipCompression }.not_to raise_error
    expect(image.compression).to eq(Magick::BZipCompression)

    Magick::CompressionType.values do |compression|
      expect { image.compression = compression }.not_to raise_error
    end
    expect { image.compression = 2 }.to raise_error(TypeError)
  end
end

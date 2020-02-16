RSpec.describe Magick::Image, '#compression' do
  it 'works' do
    img = described_class.new(100, 100)

    expect { img.compression }.not_to raise_error
    expect(img.compression).to be_instance_of(Magick::CompressionType)
    expect(img.compression).to eq(Magick::UndefinedCompression)
    expect { img.compression = Magick::BZipCompression }.not_to raise_error
    expect(img.compression).to eq(Magick::BZipCompression)

    Magick::CompressionType.values do |compression|
      expect { img.compression = compression }.not_to raise_error
    end
    expect { img.compression = 2 }.to raise_error(TypeError)
  end
end

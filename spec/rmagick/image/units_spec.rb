RSpec.describe Magick::Image, '#units' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.units }.not_to raise_error
    expect(image.units).to be_instance_of(Magick::ResolutionType)
    expect(image.units).to eq(Magick::UndefinedResolution)
    expect { image.units = Magick::PixelsPerInchResolution }.not_to raise_error
    expect(image.units).to eq(Magick::PixelsPerInchResolution)

    Magick::ResolutionType.values do |resolution|
      expect { image.units = resolution }.not_to raise_error
    end
    expect { image.units = 2 }.to raise_error(TypeError)
  end
end

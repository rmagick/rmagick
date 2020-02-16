RSpec.describe Magick::Image, '#units' do
  it 'works' do
    img = described_class.new(100, 100)

    expect { img.units }.not_to raise_error
    expect(img.units).to be_instance_of(Magick::ResolutionType)
    expect(img.units).to eq(Magick::UndefinedResolution)
    expect { img.units = Magick::PixelsPerInchResolution }.not_to raise_error
    expect(img.units).to eq(Magick::PixelsPerInchResolution)

    Magick::ResolutionType.values do |resolution|
      expect { img.units = resolution }.not_to raise_error
    end
    expect { img.units = 2 }.to raise_error(TypeError)
  end
end

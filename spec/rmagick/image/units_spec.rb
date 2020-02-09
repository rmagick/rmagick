RSpec.describe Magick::Image, '#units' do
  before do
    @img = described_class.new(100, 100)
    gc = Magick::Draw.new

    gc.stroke_width(5)
    gc.circle(50, 50, 80, 80)
    gc.draw(@img)

    @hat = described_class.read(FLOWER_HAT).first
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect { @img.units }.not_to raise_error
    expect(@img.units).to be_instance_of(Magick::ResolutionType)
    expect(@img.units).to eq(Magick::UndefinedResolution)
    expect { @img.units = Magick::PixelsPerInchResolution }.not_to raise_error
    expect(@img.units).to eq(Magick::PixelsPerInchResolution)

    Magick::ResolutionType.values do |resolution|
      expect { @img.units = resolution }.not_to raise_error
    end
    expect { @img.units = 2 }.to raise_error(TypeError)
  end
end

RSpec.describe Magick::Image, '#interlace' do
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
    expect { @img.interlace }.not_to raise_error
    expect(@img.interlace).to be_instance_of(Magick::InterlaceType)
    expect(@img.interlace).to eq(Magick::NoInterlace)
    expect { @img.interlace = Magick::LineInterlace }.not_to raise_error
    expect(@img.interlace).to eq(Magick::LineInterlace)

    Magick::InterlaceType.values do |interlace|
      expect { @img.interlace = interlace }.not_to raise_error
    end
    expect { @img.interlace = 2 }.to raise_error(TypeError)
  end
end

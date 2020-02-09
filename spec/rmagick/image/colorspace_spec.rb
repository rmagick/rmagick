RSpec.describe Magick::Image, '#colorspace' do
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
    expect { @img.colorspace }.not_to raise_error
    expect(@img.colorspace).to be_instance_of(Magick::ColorspaceType)
    expect(@img.colorspace).to eq(Magick::SRGBColorspace)
    img2 = @img.copy

    Magick::ColorspaceType.values do |colorspace|
      expect { img2.colorspace = colorspace }.not_to raise_error
    end
    expect { @img.colorspace = 2 }.to raise_error(TypeError)
    Magick::ColorspaceType.values.each do |cs|
      expect { img2.colorspace = cs }.not_to raise_error
    end
  end
end

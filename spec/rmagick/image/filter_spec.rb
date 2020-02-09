RSpec.describe Magick::Image, '#filter' do
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
    expect { @img.filter }.not_to raise_error
    expect(@img.filter).to be_instance_of(Magick::FilterType)
    expect(@img.filter).to eq(Magick::UndefinedFilter)
    expect { @img.filter = Magick::PointFilter }.not_to raise_error
    expect(@img.filter).to eq(Magick::PointFilter)

    Magick::FilterType.values do |filter|
      expect { @img.filter = filter }.not_to raise_error
    end
    expect { @img.filter = 2 }.to raise_error(TypeError)
  end
end

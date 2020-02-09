RSpec.describe Magick::Image, '#gravity' do
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
    expect(@img.gravity).to be_instance_of(Magick::GravityType)

    Magick::GravityType.values do |gravity|
      expect { @img.gravity = gravity }.not_to raise_error
    end
    expect { @img.gravity = nil }.to raise_error(TypeError)
    expect { @img.gravity = Magick::PointFilter }.to raise_error(TypeError)
  end
end

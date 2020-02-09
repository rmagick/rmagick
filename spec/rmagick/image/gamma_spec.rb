RSpec.describe Magick::Image, '#gamma' do
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
    expect { @img.gamma }.not_to raise_error
    expect(@img.gamma).to be_instance_of(Float)
    expect(@img.gamma).to eq(0.45454543828964233)
    expect { @img.gamma = 2.0 }.not_to raise_error
    expect(@img.gamma).to eq(2.0)
    expect { @img.gamma = 'x' }.to raise_error(TypeError)
  end
end

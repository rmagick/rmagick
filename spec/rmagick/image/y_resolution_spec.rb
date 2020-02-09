RSpec.describe Magick::Image, '#y_resolution' do
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
    expect { @img.y_resolution }.not_to raise_error
    expect { @img.y_resolution = 90 }.not_to raise_error
    expect(@img.y_resolution).to eq(90.0)
    expect { @img.y_resolution = 'x' }.to raise_error(TypeError)
  end
end

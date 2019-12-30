RSpec.describe Magick::Image, '#ticks_per_second' do
  before do
    @img = Magick::Image.new(100, 100)
    gc = Magick::Draw.new

    gc.stroke_width(5)
    gc.circle(50, 50, 80, 80)
    gc.draw(@img)

    @hat = Magick::Image.read(FLOWER_HAT).first
    @p = Magick::Image.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect { @img.ticks_per_second }.not_to raise_error
    expect(@img.ticks_per_second).to eq(100)
    expect { @img.ticks_per_second = 1000 }.not_to raise_error
    expect(@img.ticks_per_second).to eq(1000)
    expect { @img.ticks_per_second = 'x' }.to raise_error(TypeError)
  end
end

RSpec.describe Magick::Image, '#delay' do
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
    expect { @img.delay }.not_to raise_error
    expect(@img.delay).to eq(0)
    expect { @img.delay = 10 }.not_to raise_error
    expect(@img.delay).to eq(10)
    expect { @img.delay = 'x' }.to raise_error(TypeError)
  end
end

RSpec.describe Magick::Image, '#start_loop' do
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
    expect { @img.start_loop }.not_to raise_error
    expect(@img.start_loop).to be(false)
    expect { @img.start_loop = true }.not_to raise_error
    expect(@img.start_loop).to be(true)
  end
end

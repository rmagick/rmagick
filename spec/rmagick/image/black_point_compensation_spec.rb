RSpec.describe Magick::Image, '#black_point_compensation' do
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
    expect { @img.black_point_compensation = true }.not_to raise_error
    expect(@img.black_point_compensation).to be(true)
    expect { @img.black_point_compensation = false }.not_to raise_error
    expect(@img.black_point_compensation).to be(false)
  end
end

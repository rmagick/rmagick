RSpec.describe Magick::Image, '#total_colors' do
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
    expect { @hat.total_colors }.not_to raise_error
    expect(@hat.total_colors).to be_kind_of(Integer)
    expect { @img.total_colors = 2 }.to raise_error(NoMethodError)
  end
end

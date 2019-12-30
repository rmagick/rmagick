RSpec.describe Magick::Image, '#color_profile' do
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
    expect { @img.color_profile }.not_to raise_error
    expect(@img.color_profile).to be(nil)
    expect { @img.color_profile = @p }.not_to raise_error
    expect(@img.color_profile).to eq(@p)
    expect { @img.color_profile = 2 }.to raise_error(TypeError)
  end
end

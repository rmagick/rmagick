RSpec.describe Magick::Image, '#directory' do
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
    expect { @img.directory }.not_to raise_error
    expect(@img.directory).to be(nil)
    expect { @img.directory = nil }.to raise_error(NoMethodError)
  end
end

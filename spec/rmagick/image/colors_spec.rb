RSpec.describe Magick::Image, '#colors' do
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
    expect { @img.colors }.not_to raise_error
    expect(@img.colors).to eq(0)
    img = @img.copy
    img.class_type = Magick::PseudoClass
    expect(img.colors).to be_kind_of(Integer)
    expect { img.colors = 2 }.to raise_error(NoMethodError)
  end
end

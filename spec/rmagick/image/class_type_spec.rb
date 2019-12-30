RSpec.describe Magick::Image, '#class_type' do
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
    expect { @img.class_type }.not_to raise_error
    expect(@img.class_type).to be_instance_of(Magick::ClassType)
    expect(@img.class_type).to eq(Magick::DirectClass)
    expect { @img.class_type = Magick::PseudoClass }.not_to raise_error
    expect(@img.class_type).to eq(Magick::PseudoClass)
    expect { @img.class_type = 2 }.to raise_error(TypeError)

    expect do
      @img.class_type = Magick::PseudoClass
      @img.class_type = Magick::DirectClass
      expect(@img.class_type).to eq(Magick::DirectClass)
    end.not_to raise_error
  end
end

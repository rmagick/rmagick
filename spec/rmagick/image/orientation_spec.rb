RSpec.describe Magick::Image, '#orientation' do
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
    expect { @img.orientation }.not_to raise_error
    expect(@img.orientation).to be_instance_of(Magick::OrientationType)
    expect(@img.orientation).to eq(Magick::UndefinedOrientation)
    expect { @img.orientation = Magick::TopLeftOrientation }.not_to raise_error
    expect(@img.orientation).to eq(Magick::TopLeftOrientation)

    Magick::OrientationType.values do |orientation|
      expect { @img.orientation = orientation }.not_to raise_error
    end
    expect { @img.orientation = 2 }.to raise_error(TypeError)
  end
end

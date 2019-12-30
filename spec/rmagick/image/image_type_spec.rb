RSpec.describe Magick::Image, '#image_type' do
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
    expect(@img.image_type).to be_instance_of(Magick::ImageType)

    Magick::ImageType.values do |image_type|
      expect { @img.image_type = image_type }.not_to raise_error
    end
    expect { @img.image_type = nil }.to raise_error(TypeError)
    expect { @img.image_type = Magick::PointFilter }.to raise_error(TypeError)
  end
end

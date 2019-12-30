RSpec.describe Magick::Image, '#pixel_interpolation_method' do
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
    expect { @img.pixel_interpolation_method }.not_to raise_error
    expect(@img.pixel_interpolation_method).to be_instance_of(Magick::PixelInterpolateMethod)
    expect(@img.pixel_interpolation_method).to eq(Magick::UndefinedInterpolatePixel)
    expect { @img.pixel_interpolation_method = Magick::AverageInterpolatePixel }.not_to raise_error
    expect(@img.pixel_interpolation_method).to eq(Magick::AverageInterpolatePixel)

    Magick::PixelInterpolateMethod.values do |interpolate_pixel_method|
      expect { @img.pixel_interpolation_method = interpolate_pixel_method }.not_to raise_error
    end
    expect { @img.pixel_interpolation_method = 2 }.to raise_error(TypeError)
  end
end

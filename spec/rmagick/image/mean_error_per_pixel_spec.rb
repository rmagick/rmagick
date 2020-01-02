RSpec.describe Magick::Image, '#mean_error_per_pixel' do
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
    expect { @hat.mean_error_per_pixel }.not_to raise_error
    expect { @hat.normalized_mean_error }.not_to raise_error
    expect { @hat.normalized_maximum_error }.not_to raise_error
    expect(@hat.mean_error_per_pixel).to eq(0.0)
    expect(@hat.normalized_mean_error).to eq(0.0)
    expect(@hat.normalized_maximum_error).to eq(0.0)

    hat = @hat.quantize(16, Magick::RGBColorspace, true, 0, true)

    expect(hat.mean_error_per_pixel).not_to eq(0.0)
    expect(hat.normalized_mean_error).not_to eq(0.0)
    expect(hat.normalized_maximum_error).not_to eq(0.0)
    expect { hat.mean_error_per_pixel = 1 }.to raise_error(NoMethodError)
    expect { hat.normalized_mean_error = 1 }.to raise_error(NoMethodError)
    expect { hat.normalized_maximum_error = 1 }.to raise_error(NoMethodError)
  end
end

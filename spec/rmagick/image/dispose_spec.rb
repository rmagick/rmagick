RSpec.describe Magick::Image, '#dispose' do
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
    expect { @img.dispose }.not_to raise_error
    expect(@img.dispose).to be_instance_of(Magick::DisposeType)
    expect(@img.dispose).to eq(Magick::UndefinedDispose)
    expect { @img.dispose = Magick::NoneDispose }.not_to raise_error
    expect(@img.dispose).to eq(Magick::NoneDispose)

    Magick::DisposeType.values do |dispose|
      expect { @img.dispose = dispose }.not_to raise_error
    end
    expect { @img.dispose = 2 }.to raise_error(TypeError)
  end
end

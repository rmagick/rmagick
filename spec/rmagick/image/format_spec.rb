RSpec.describe Magick::Image, '#format' do
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
    expect { @img.format }.not_to raise_error
    expect(@img.format).to be(nil)
    expect { @img.format = 'GIF' }.not_to raise_error
    expect { @img.format = 'JPG' }.not_to raise_error
    expect { @img.format = 'TIFF' }.not_to raise_error
    expect { @img.format = 'MIFF' }.not_to raise_error
    expect { @img.format = 'MPEG' }.not_to raise_error
    v = $VERBOSE
    $VERBOSE = nil
    expect { @img.format = 'shit' }.to raise_error(ArgumentError)
    $VERBOSE = v
    expect { @img.format = 2 }.to raise_error(TypeError)
  end
end

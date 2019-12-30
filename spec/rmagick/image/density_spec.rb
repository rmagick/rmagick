RSpec.describe Magick::Image, '#density' do
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
    expect { @img.density }.not_to raise_error
    expect { @img.density = '90x90' }.not_to raise_error
    expect { @img.density = 'x90' }.not_to raise_error
    expect { @img.density = '90' }.not_to raise_error
    expect { @img.density = Magick::Geometry.new(@img.columns / 2, @img.rows / 2, 5, 5) }.not_to raise_error
    expect { @img.density = 2 }.to raise_error(TypeError)
  end
end

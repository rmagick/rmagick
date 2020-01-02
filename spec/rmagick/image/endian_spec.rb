RSpec.describe Magick::Image, '#endian' do
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
    expect { @img.endian }.not_to raise_error
    expect(@img.endian).to be_instance_of(Magick::EndianType)
    expect(@img.endian).to eq(Magick::UndefinedEndian)
    expect { @img.endian = Magick::LSBEndian }.not_to raise_error
    expect(@img.endian).to eq(Magick::LSBEndian)
    expect { @img.endian = Magick::MSBEndian }.not_to raise_error
    expect { @img.endian = 2 }.to raise_error(TypeError)
  end
end

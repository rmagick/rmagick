RSpec.describe Magick::Image, '#compression' do
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
    expect { @img.compression }.not_to raise_error
    expect(@img.compression).to be_instance_of(Magick::CompressionType)
    expect(@img.compression).to eq(Magick::UndefinedCompression)
    expect { @img.compression = Magick::BZipCompression }.not_to raise_error
    expect(@img.compression).to eq(Magick::BZipCompression)

    Magick::CompressionType.values do |compression|
      expect { @img.compression = compression }.not_to raise_error
    end
    expect { @img.compression = 2 }.to raise_error(TypeError)
  end
end

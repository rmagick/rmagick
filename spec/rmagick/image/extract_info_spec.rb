RSpec.describe Magick::Image, '#extract_info' do
  before do
    @img = described_class.new(100, 100)
    gc = Magick::Draw.new

    gc.stroke_width(5)
    gc.circle(50, 50, 80, 80)
    gc.draw(@img)

    @hat = described_class.read(FLOWER_HAT).first
    @p = described_class.read(IMAGE_WITH_PROFILE).first.color_profile
  end

  it 'works' do
    expect { @img.extract_info }.not_to raise_error
    expect(@img.extract_info).to be_instance_of(Magick::Rectangle)
    ext = @img.extract_info
    expect(ext.x).to eq(0)
    expect(ext.y).to eq(0)
    expect(ext.width).to eq(0)
    expect(ext.height).to eq(0)
    ext = Magick::Rectangle.new(1, 2, 3, 4)
    expect { @img.extract_info = ext }.not_to raise_error
    expect(ext.width).to eq(1)
    expect(ext.height).to eq(2)
    expect(ext.x).to eq(3)
    expect(ext.y).to eq(4)
    expect { @img.extract_info = 2 }.to raise_error(TypeError)
  end
end

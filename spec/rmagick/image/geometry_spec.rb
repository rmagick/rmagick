RSpec.describe Magick::Image, '#geometry' do
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
    expect { @img.geometry }.not_to raise_error
    expect(@img.geometry).to be(nil)
    expect { @img.geometry = nil }.not_to raise_error
    expect { @img.geometry = '90x90' }.not_to raise_error
    expect(@img.geometry).to eq('90x90')
    expect { @img.geometry = Magick::Geometry.new(100, 80) }.not_to raise_error
    expect(@img.geometry).to eq('100x80')
    expect { @img.geometry = [] }.to raise_error(TypeError)
  end
end

RSpec.describe Magick::Image, '#rows' do
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
    expect { @img.rows }.not_to raise_error
    expect(@img.rows).to eq(100)
    expect { @img.rows = 2 }.to raise_error(NoMethodError)
  end
end

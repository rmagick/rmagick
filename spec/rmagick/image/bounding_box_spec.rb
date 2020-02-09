RSpec.describe Magick::Image, '#bounding_box' do
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
    expect { @img.bounding_box }.not_to raise_error
    box = @img.bounding_box
    expect(box.width).to eq(87)
    expect(box.height).to eq(87)
    expect(box.x).to eq(7)
    expect(box.y).to eq(7)
    expect { @img.bounding_box = 2 }.to raise_error(NoMethodError)
  end
end

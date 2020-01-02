RSpec.describe Magick::Image, '#quantum_depth' do
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
    expect { @img.quantum_depth }.not_to raise_error
    expect(@img.quantum_depth).to eq(Magick::MAGICKCORE_QUANTUM_DEPTH)
    expect { @img.quantum_depth = 8 }.to raise_error(NoMethodError)
  end
end

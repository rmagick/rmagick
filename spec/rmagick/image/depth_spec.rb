RSpec.describe Magick::Image, '#depth' do
  before do
    @img = described_class.new(100, 100)
    gc = Magick::Draw.new

    gc.stroke_width(5)
    gc.circle(50, 50, 80, 80)
    gc.draw(@img)
  end

  it 'works' do
    expect(@img.depth).to eq(Magick::MAGICKCORE_QUANTUM_DEPTH)
    expect { @img.depth = 2 }.to raise_error(NoMethodError)
  end
end

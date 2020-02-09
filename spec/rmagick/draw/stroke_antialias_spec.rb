RSpec.describe Magick::Draw, '#stroke_antialias' do
  before do
    @draw = described_class.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    draw = described_class.new
    draw.stroke_antialias(true)
    expect(draw.inspect).to eq('stroke-antialias 1')
    draw.stroke_pattern('red')
    draw.stroke_width(5)
    draw.circle(10, '20.5', 30, 40.5)
    expect { draw.draw(@img) }.not_to raise_error

    draw = described_class.new
    draw.stroke_antialias(false)
    expect(draw.inspect).to eq('stroke-antialias 0')
    draw.stroke_pattern('red')
    draw.stroke_width(5)
    draw.circle(10, '20.5', 30, 40.5)
    expect { draw.draw(@img) }.not_to raise_error
  end
end

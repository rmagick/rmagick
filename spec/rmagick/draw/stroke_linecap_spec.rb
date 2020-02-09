RSpec.describe Magick::Draw, '#stroke_linecap' do
  before do
    @draw = described_class.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    draw = described_class.new
    draw.stroke_linecap('butt')
    expect(draw.inspect).to eq('stroke-linecap butt')
    expect { draw.draw(@img) }.not_to raise_error

    draw = described_class.new
    draw.stroke_linecap('round')
    expect(draw.inspect).to eq('stroke-linecap round')
    expect { draw.draw(@img) }.not_to raise_error

    draw = described_class.new
    draw.stroke_linecap('square')
    expect(draw.inspect).to eq('stroke-linecap square')
    expect { draw.draw(@img) }.not_to raise_error

    expect { @draw.stroke_linecap('foo') }.to raise_error(ArgumentError)
  end
end

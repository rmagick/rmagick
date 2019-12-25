RSpec.describe Magick::Draw, '#stroke_linejoin' do
  before do
    @draw = Magick::Draw.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    draw = Magick::Draw.new
    draw.stroke_linejoin('round')
    expect(draw.inspect).to eq('stroke-linejoin round')
    expect { draw.draw(@img) }.not_to raise_error

    draw = Magick::Draw.new
    draw.stroke_linejoin('miter')
    expect(draw.inspect).to eq('stroke-linejoin miter')
    expect { draw.draw(@img) }.not_to raise_error

    draw = Magick::Draw.new
    draw.stroke_linejoin('bevel')
    expect(draw.inspect).to eq('stroke-linejoin bevel')
    expect { draw.draw(@img) }.not_to raise_error

    expect { @draw.stroke_linejoin('foo') }.to raise_error(ArgumentError)
  end
end

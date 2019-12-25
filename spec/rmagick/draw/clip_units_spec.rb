RSpec.describe Magick::Draw, '#clip_units' do
  before do
    @draw = Magick::Draw.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    draw = Magick::Draw.new
    draw.clip_units('userspace')
    expect(draw.inspect).to eq('clip-units userspace')
    expect { draw.draw(@img) }.not_to raise_error

    draw = Magick::Draw.new
    draw.clip_units('userspaceonuse')
    expect(draw.inspect).to eq('clip-units userspaceonuse')
    expect { draw.draw(@img) }.not_to raise_error

    draw = Magick::Draw.new
    draw.clip_units('objectboundingbox')
    expect(draw.inspect).to eq('clip-units objectboundingbox')
    expect { draw.draw(@img) }.not_to raise_error

    expect { @draw.clip_units('foo') }.to raise_error(ArgumentError)
  end
end

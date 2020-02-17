RSpec.describe Magick::Draw, '#clip_units' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.clip_units('userspace')
    expect(draw.inspect).to eq('clip-units userspace')
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.clip_units('userspaceonuse')
    expect(draw.inspect).to eq('clip-units userspaceonuse')
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.clip_units('objectboundingbox')
    expect(draw.inspect).to eq('clip-units objectboundingbox')
    expect { draw.draw(image) }.not_to raise_error

    expect { draw.clip_units('foo') }.to raise_error(ArgumentError)
  end
end

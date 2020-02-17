RSpec.describe Magick::Draw, '#stroke_linejoin' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.stroke_linejoin('round')
    expect(draw.inspect).to eq('stroke-linejoin round')
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.stroke_linejoin('miter')
    expect(draw.inspect).to eq('stroke-linejoin miter')
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.stroke_linejoin('bevel')
    expect(draw.inspect).to eq('stroke-linejoin bevel')
    expect { draw.draw(image) }.not_to raise_error

    expect { draw.stroke_linejoin('foo') }.to raise_error(ArgumentError)
  end
end

RSpec.describe Magick::Draw, '#stroke_dasharray' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.stroke_dasharray(2, 2)
    expect(draw.inspect).to eq('stroke-dasharray 2,2')
    draw.stroke_pattern('red')
    draw.stroke_width(2)
    draw.rectangle(10, '10', 100, 100)
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.stroke_dasharray
    expect(draw.inspect).to eq('stroke-dasharray none')
    expect { draw.draw(image) }.not_to raise_error

    expect { draw.stroke_dasharray(-0.1) }.to raise_error(ArgumentError)
    expect { draw.stroke_dasharray('x') }.to raise_error(ArgumentError)
  end
end

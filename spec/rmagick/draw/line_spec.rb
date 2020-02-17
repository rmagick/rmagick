RSpec.describe Magick::Draw, '#line' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.line(10, '20.5', 30, 40.5)
    expect(draw.inspect).to eq('line 10,20.5 30,40.5')
    expect { draw.draw(image) }.not_to raise_error

    expect { draw.line('x', '20.5', 30, 40.5) }.to raise_error(ArgumentError)
    expect { draw.line(10, 'x', 30, 40.5) }.to raise_error(ArgumentError)
    expect { draw.line(10, '20.5', 'x', 40.5) }.to raise_error(ArgumentError)
    expect { draw.line(10, '20.5', 30, 'x') }.to raise_error(ArgumentError)
  end
end

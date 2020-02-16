RSpec.describe Magick::Draw, '#roundrectangle' do
  it 'works' do
    draw = described_class.new
    img = Magick::Image.new(200, 200)

    draw.roundrectangle(10, '10', 100, 100, 20, 20)
    expect(draw.inspect).to eq('roundrectangle 10,10,100,100,20,20')
    expect { draw.draw(img) }.not_to raise_error

    expect { draw.roundrectangle('x', '10', 100, 100, 20, 20) }.to raise_error(ArgumentError)
    expect { draw.roundrectangle(10, 'x', 100, 100, 20, 20) }.to raise_error(ArgumentError)
    expect { draw.roundrectangle(10, '10', 'x', 100, 20, 20) }.to raise_error(ArgumentError)
    expect { draw.roundrectangle(10, '10', 100, 'x', 20, 20) }.to raise_error(ArgumentError)
    expect { draw.roundrectangle(10, '10', 100, 100, 'x', 20) }.to raise_error(ArgumentError)
    expect { draw.roundrectangle(10, '10', 100, 100, 20, 'x') }.to raise_error(ArgumentError)
  end
end

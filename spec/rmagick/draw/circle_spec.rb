RSpec.describe Magick::Draw, '#circle' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.circle(10, '20.5', 30, 40.5)
    expect(draw.inspect).to eq('circle 10,20.5 30,40.5')
    expect { draw.draw(image) }.not_to raise_error

    expect { draw.circle('x', 20, 30, 40) }.to raise_error(ArgumentError)
    expect { draw.circle(10, 'x', 30, 40) }.to raise_error(ArgumentError)
    expect { draw.circle(10, 20, 'x', 40) }.to raise_error(ArgumentError)
    expect { draw.circle(10, 20, 30, 'x') }.to raise_error(ArgumentError)
  end
end

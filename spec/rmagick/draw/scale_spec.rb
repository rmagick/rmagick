RSpec.describe Magick::Draw, '#scale' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.scale('0.5', 1.5)
    expect(draw.inspect).to eq('scale 0.5,1.5')
    draw.rectangle(10, '10', 100, 100)
    expect { draw.draw(image) }.not_to raise_error

    expect { draw.scale('x', 1.5) }.to raise_error(ArgumentError)
    expect { draw.scale(0.5, 'x') }.to raise_error(ArgumentError)
  end
end

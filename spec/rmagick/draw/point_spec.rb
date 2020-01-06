RSpec.describe Magick::Draw, '#point' do
  it 'works' do
    draw = described_class.new
    img = Magick::Image.new(200, 200)

    draw.point(10.5, '20')
    expect(draw.inspect).to eq('point 10.5,20')
    expect { draw.draw(img) }.not_to raise_error

    expect { draw.point('x', 20) }.to raise_error(ArgumentError)
    expect { draw.point(10, 'x') }.to raise_error(ArgumentError)
  end
end

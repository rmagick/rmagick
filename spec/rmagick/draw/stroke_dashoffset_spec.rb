RSpec.describe Magick::Draw, '#stroke_dashoffset' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.stroke_dashoffset(10)
    expect(draw.inspect).to eq('stroke-dashoffset 10')
    expect { draw.draw(image) }.not_to raise_error

    expect { draw.stroke_dashoffset('x') }.to raise_error(ArgumentError)
  end
end

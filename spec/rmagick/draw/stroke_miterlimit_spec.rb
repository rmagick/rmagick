RSpec.describe Magick::Draw, '#stroke_miterlimit' do
  it 'works' do
    draw = described_class.new
    img = Magick::Image.new(200, 200)

    draw.stroke_miterlimit(1.0)
    expect(draw.inspect).to eq('stroke-miterlimit 1.0')
    expect { draw.draw(img) }.not_to raise_error

    expect { draw.stroke_miterlimit(0.9) }.to raise_error(ArgumentError)
    expect { draw.stroke_miterlimit('foo') }.to raise_error(ArgumentError)
  end
end

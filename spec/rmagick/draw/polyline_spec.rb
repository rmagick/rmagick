RSpec.describe Magick::Draw, '#polyline' do
  it 'works' do
    draw = described_class.new
    img = Magick::Image.new(200, 200)

    draw.polyline(0, '0.5', 16.5, 16)
    expect(draw.inspect).to eq('polyline 0,0.5,16.5,16')
    expect { draw.draw(img) }.not_to raise_error

    expect { draw.polyline }.to raise_error(ArgumentError)
    expect { draw.polyline(0) }.to raise_error(ArgumentError)
    expect { draw.polyline('x', 0, 16, 16) }.to raise_error(ArgumentError)
  end
end

RSpec.describe Magick::Draw, '#polygon' do
  it 'works' do
    draw = described_class.new
    img = Magick::Image.new(200, 200)

    draw.polygon(0, '0.5', 8.5, 16, 16, 0, 0, 0)
    expect(draw.inspect).to eq('polygon 0,0.5,8.5,16,16,0,0,0')
    expect { draw.draw(img) }.not_to raise_error

    expect { draw.polygon }.to raise_error(ArgumentError)
    expect { draw.polygon(0) }.to raise_error(ArgumentError)
    expect { draw.polygon('x', 0, 8, 16, 16, 0, 0, 0) }.to raise_error(ArgumentError)
  end
end

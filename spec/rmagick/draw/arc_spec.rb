RSpec.describe Magick::Draw, '#arc' do
  it 'works' do
    draw = described_class.new
    img = Magick::Image.new(200, 200)

    draw.arc(100.5, 120.5, 200, 250, 20, 370)
    expect(draw.inspect).to eq('arc 100.5,120.5 200,250 20,370')
    expect { draw.draw(img) }.not_to raise_error

    expect { draw.arc('x', 120.5, 200, 250, 20, 370) }.to raise_error(ArgumentError)
    expect { draw.arc(100.5, 'x', 200, 250, 20, 370) }.to raise_error(ArgumentError)
    expect { draw.arc(100.5, 120.5, 'x', 250, 20, 370) }.to raise_error(ArgumentError)
    expect { draw.arc(100.5, 120.5, 200, 'x', 20, 370) }.to raise_error(ArgumentError)
    expect { draw.arc(100.5, 120.5, 200, 250, 'x', 370) }.to raise_error(ArgumentError)
    expect { draw.arc(100.5, 120.5, 200, 250, 20, 'x') }.to raise_error(ArgumentError)
  end
end

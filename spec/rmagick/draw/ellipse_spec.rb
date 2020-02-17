RSpec.describe Magick::Draw, '#ellipse' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.ellipse(50.5, 30, 25, 25, 60, 120)
    expect(draw.inspect).to eq('ellipse 50.5,30 25,25 60,120')
    expect { draw.draw(image) }.not_to raise_error

    expect { draw.ellipse('x', 20, 30, 40, 50, 60) }.to raise_error(ArgumentError)
    expect { draw.ellipse(10, 'x', 30, 40, 50, 60) }.to raise_error(ArgumentError)
    expect { draw.ellipse(10, 20, 'x', 40, 50, 60) }.to raise_error(ArgumentError)
    expect { draw.ellipse(10, 20, 30, 'x', 50, 60) }.to raise_error(ArgumentError)
    expect { draw.ellipse(10, 20, 30, 40, 'x', 60) }.to raise_error(ArgumentError)
    expect { draw.ellipse(10, 20, 30, 40, 50, 'x') }.to raise_error(ArgumentError)
  end
end

RSpec.describe Magick::Draw, '#color' do
  it 'works' do
    draw = described_class.new
    img = Magick::Image.new(200, 200)

    draw.color(50.5, 50, Magick::PointMethod)
    expect(draw.inspect).to eq('color 50.5,50,point')
    expect { draw.draw(img) }.not_to raise_error

    draw = described_class.new
    draw.color(50.5, 50, Magick::ReplaceMethod)
    expect(draw.inspect).to eq('color 50.5,50,replace')
    expect { draw.draw(img) }.not_to raise_error

    draw = described_class.new
    draw.color(50.5, 50, Magick::FloodfillMethod)
    expect(draw.inspect).to eq('color 50.5,50,floodfill')
    expect { draw.draw(img) }.not_to raise_error

    draw = described_class.new
    draw.color(50.5, 50, Magick::FillToBorderMethod)
    expect(draw.inspect).to eq('color 50.5,50,filltoborder')
    expect { draw.draw(img) }.not_to raise_error

    draw = described_class.new
    draw.color(50.5, 50, Magick::ResetMethod)
    expect(draw.inspect).to eq('color 50.5,50,reset')
    expect { draw.draw(img) }.not_to raise_error

    expect { draw.color(10, 20, 'unknown') }.to raise_error(ArgumentError)
    expect { draw.color('x', 20, Magick::PointMethod) }.to raise_error(ArgumentError)
    expect { draw.color(10, 'x', Magick::PointMethod) }.to raise_error(ArgumentError)
  end
end

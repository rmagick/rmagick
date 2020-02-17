RSpec.describe Magick::Draw, '#alpha' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    Magick::PaintMethod.values do |method|
      draw = described_class.new
      draw.alpha(10, '20.5', method)
      expect { draw.draw(image) }.not_to raise_error
    end

    expect { draw.alpha(10, '20.5', 'xxx') }.to raise_error(ArgumentError)
    expect { draw.alpha('x', 10, Magick::PointMethod) }.to raise_error(ArgumentError)
    expect { draw.alpha(10, 'x', Magick::PointMethod) }.to raise_error(ArgumentError)
  end
end

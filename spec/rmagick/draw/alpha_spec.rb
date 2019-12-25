RSpec.describe Magick::Draw, '#alpha' do
  before do
    @draw = Magick::Draw.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    Magick::PaintMethod.values do |method|
      draw = Magick::Draw.new
      draw.alpha(10, '20.5', method)
      expect { draw.draw(@img) }.not_to raise_error
    end

    expect { @draw.alpha(10, '20.5', 'xxx') }.to raise_error(ArgumentError)
    expect { @draw.alpha('x', 10, Magick::PointMethod) }.to raise_error(ArgumentError)
    expect { @draw.alpha(10, 'x', Magick::PointMethod) }.to raise_error(ArgumentError)
  end
end

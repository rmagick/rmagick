RSpec.describe Magick::Draw, '#draw' do
  before do
    @draw = described_class.new
  end

  it 'works' do
    draw2 = @draw.dup

    img = Magick::Image.new(10, 10)
    @draw.path('M110,100 h-75 a75,75 0 1,0 75,-75 z')
    expect { @draw.draw(img) }.not_to raise_error

    expect { draw2.draw(img) }.to raise_error(ArgumentError)
    expect { draw2.draw('x') }.to raise_error(NoMethodError)
  end
end

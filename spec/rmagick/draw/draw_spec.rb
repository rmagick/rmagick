RSpec.describe Magick::Draw, '#draw' do
  before do
    @draw = Magick::Draw.new
  end

  it 'works' do
    draw = @draw.dup

    img = Magick::Image.new(10, 10)
    @draw.path('M110,100 h-75 a75,75 0 1,0 75,-75 z')
    expect { @draw.draw(img) }.not_to raise_error

    expect { draw.draw(img) }.to raise_error(ArgumentError)
    expect { draw.draw('x') }.to raise_error(NoMethodError)
  end
end

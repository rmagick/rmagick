RSpec.describe Magick::Draw, '#draw' do
  it 'works' do
    draw1 = described_class.new
    draw2 = draw1.dup

    img = Magick::Image.new(10, 10)
    draw1.path('M110,100 h-75 a75,75 0 1,0 75,-75 z')
    expect { draw1.draw(img) }.not_to raise_error

    expect { draw2.draw(img) }.to raise_error(ArgumentError)
    expect { draw2.draw('x') }.to raise_error(NoMethodError)
  end
end

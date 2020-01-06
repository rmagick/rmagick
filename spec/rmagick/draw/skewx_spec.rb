RSpec.describe Magick::Draw, '#skewx' do
  it 'works' do
    draw = described_class.new
    img = Magick::Image.new(200, 200)

    draw.skewx(45)
    expect(draw.inspect).to eq('skewX 45')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(img) }.not_to raise_error

    expect { draw.skewx('x') }.to raise_error(ArgumentError)
  end
end

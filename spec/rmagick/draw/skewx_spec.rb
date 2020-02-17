RSpec.describe Magick::Draw, '#skewx' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.skewx(45)
    expect(draw.inspect).to eq('skewX 45')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(image) }.not_to raise_error

    expect { draw.skewx('x') }.to raise_error(ArgumentError)
  end
end

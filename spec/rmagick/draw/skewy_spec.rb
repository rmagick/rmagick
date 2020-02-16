RSpec.describe Magick::Draw, '#skewy' do
  it 'works' do
    draw = described_class.new
    img = Magick::Image.new(200, 200)

    draw.skewy(45)
    expect(draw.inspect).to eq('skewY 45')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(img) }.not_to raise_error

    expect { draw.skewy('x') }.to raise_error(ArgumentError)
  end
end

RSpec.describe Magick::Draw, '#rotate' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.rotate(45)
    expect(draw.inspect).to eq('rotate 45')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(image) }.not_to raise_error

    expect { draw.rotate('x') }.to raise_error(ArgumentError)
  end
end

RSpec.describe Magick::Draw, '#pointsize' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.pointsize(20.5)
    expect(draw.inspect).to eq('font-size 20.5')
    expect { draw.draw(image) }.not_to raise_error

    expect { draw.pointsize('x') }.to raise_error(ArgumentError)
  end
end

RSpec.describe Magick::Draw, '#stroke_color' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.stroke_color('red')
    expect(draw.inspect).to eq('stroke "red"')
    draw.rectangle(10, '10', 100, 100)
    expect { draw.draw(image) }.not_to raise_error

    # expect { draw.stroke_color(100) }.to raise_error(ArgumentError)
  end
end

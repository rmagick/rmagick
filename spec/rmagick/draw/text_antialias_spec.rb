RSpec.describe Magick::Draw, '#text_antialias' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.text_antialias(true)
    expect(draw.inspect).to eq('text-antialias 1')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.text_antialias(false)
    expect(draw.inspect).to eq('text-antialias 0')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(image) }.not_to raise_error
  end
end

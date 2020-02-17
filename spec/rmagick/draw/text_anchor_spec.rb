RSpec.describe Magick::Draw, '#text_anchor' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.text_anchor(Magick::StartAnchor)
    expect(draw.inspect).to eq('text-anchor start')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.text_anchor(Magick::MiddleAnchor)
    expect(draw.inspect).to eq('text-anchor middle')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.text_anchor(Magick::EndAnchor)
    expect(draw.inspect).to eq('text-anchor end')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(image) }.not_to raise_error

    expect { draw.text_anchor('x') }.to raise_error(ArgumentError)
  end
end

RSpec.describe Magick::Draw, '#font_style' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.font_style(Magick::NormalStyle)
    expect(draw.inspect).to eq('font-style normal')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.font_style(Magick::ItalicStyle)
    expect(draw.inspect).to eq('font-style italic')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.font_style(Magick::ObliqueStyle)
    expect(draw.inspect).to eq('font-style oblique')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(image) }.not_to raise_error

    expect { draw.font_style('xxx') }.to raise_error(ArgumentError)
  end
end

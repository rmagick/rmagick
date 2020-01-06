RSpec.describe Magick::Draw, '#decorate' do
  it 'works' do
    draw = described_class.new
    img = Magick::Image.new(200, 200)

    draw.decorate(Magick::NoDecoration)
    expect(draw.inspect).to eq('decorate none')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(img) }.not_to raise_error

    draw = described_class.new
    draw.decorate(Magick::UnderlineDecoration)
    expect(draw.inspect).to eq('decorate underline')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(img) }.not_to raise_error

    draw = described_class.new
    draw.decorate(Magick::OverlineDecoration)
    expect(draw.inspect).to eq('decorate overline')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(img) }.not_to raise_error

    draw = described_class.new
    draw.decorate(Magick::OverlineDecoration)
    expect(draw.inspect).to eq('decorate overline')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(img) }.not_to raise_error

    # draw = Magick::Draw.new
    # draw.decorate('tomato')
    # expect(draw.inspect).to eq('decorate "tomato"')
    # draw.text(50, 50, 'Hello world')
    # expect { draw.draw(img) }.not_to raise_error
  end
end

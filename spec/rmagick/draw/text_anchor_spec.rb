RSpec.describe Magick::Draw, '#text_anchor' do
  before do
    @draw = Magick::Draw.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    draw = Magick::Draw.new
    draw.text_anchor(Magick::StartAnchor)
    expect(draw.inspect).to eq('text-anchor start')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(@img) }.not_to raise_error

    draw = Magick::Draw.new
    draw.text_anchor(Magick::MiddleAnchor)
    expect(draw.inspect).to eq('text-anchor middle')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(@img) }.not_to raise_error

    draw = Magick::Draw.new
    draw.text_anchor(Magick::EndAnchor)
    expect(draw.inspect).to eq('text-anchor end')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(@img) }.not_to raise_error

    expect { @draw.text_anchor('x') }.to raise_error(ArgumentError)
  end
end

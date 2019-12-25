RSpec.describe Magick::Draw, '#text_antialias' do
  before do
    @draw = Magick::Draw.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    draw = Magick::Draw.new
    draw.text_antialias(true)
    expect(draw.inspect).to eq('text-antialias 1')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(@img) }.not_to raise_error

    draw = Magick::Draw.new
    draw.text_antialias(false)
    expect(draw.inspect).to eq('text-antialias 0')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(@img) }.not_to raise_error
  end
end

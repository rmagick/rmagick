RSpec.describe Magick::Draw, '#fill' do
  before do
    @draw = described_class.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    draw = described_class.new
    draw.fill('tomato')
    expect(draw.inspect).to eq('fill "tomato"')
    draw.circle(10, '20.5', 30, 40.5)
    expect { draw.draw(@img) }.not_to raise_error

    draw = described_class.new
    draw.fill_color('tomato')
    expect(draw.inspect).to eq('fill "tomato"')
    draw.circle(10, '20.5', 30, 40.5)
    expect { draw.draw(@img) }.not_to raise_error

    draw = described_class.new
    draw.fill_pattern('tomato')
    expect(draw.inspect).to eq('fill "tomato"')
    draw.circle(10, '20.5', 30, 40.5)
    expect { draw.draw(@img) }.not_to raise_error

    # draw = Magick::Draw.new
    # draw.fill_pattern('foo')
    # expect { draw.draw(@img) }.not_to raise_error
  end
end

RSpec.describe Magick::Draw, '#font_weight' do
  before do
    @draw = Magick::Draw.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    Magick::WeightType.values do |weight|
      draw = Magick::Draw.new
      draw.font_weight(weight)
      draw.text(50, 50, 'Hello world')
      expect { draw.draw(@img) }.not_to raise_error
    end

    draw = Magick::Draw.new
    draw.font_weight(400)
    expect(draw.inspect).to eq('font-weight 400')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(@img) }.not_to raise_error

    expect { @draw.font_weight('xxx') }.to raise_error(ArgumentError)
  end
end

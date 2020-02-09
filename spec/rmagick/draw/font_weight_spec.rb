RSpec.describe Magick::Draw, '#font_weight' do
  before do
    @draw = described_class.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    Magick::WeightType.values do |weight|
      draw = described_class.new
      draw.font_weight(weight)
      draw.text(50, 50, 'Hello world')
      expect { draw.draw(@img) }.not_to raise_error
    end

    draw = described_class.new
    draw.font_weight(400)
    expect(draw.inspect).to eq('font-weight 400')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(@img) }.not_to raise_error

    expect { @draw.font_weight('xxx') }.to raise_error(ArgumentError)
  end
end

RSpec.describe Magick::Draw, '#stroke_width' do
  before do
    @draw = described_class.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    @draw.stroke_width(2.5)
    expect(@draw.inspect).to eq('stroke-width 2.5')
    expect { @draw.draw(@img) }.not_to raise_error

    expect { @draw.stroke_width('xxx') }.to raise_error(ArgumentError)
  end
end

RSpec.describe Magick::Draw, '#stroke_dashoffset' do
  before do
    @draw = described_class.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    @draw.stroke_dashoffset(10)
    expect(@draw.inspect).to eq('stroke-dashoffset 10')
    expect { @draw.draw(@img) }.not_to raise_error

    expect { @draw.stroke_dashoffset('x') }.to raise_error(ArgumentError)
  end
end

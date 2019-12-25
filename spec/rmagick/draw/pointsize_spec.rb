RSpec.describe Magick::Draw, '#pointsize' do
  before do
    @draw = Magick::Draw.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    @draw.pointsize(20.5)
    expect(@draw.inspect).to eq('font-size 20.5')
    expect { @draw.draw(@img) }.not_to raise_error

    expect { @draw.pointsize('x') }.to raise_error(ArgumentError)
  end
end

RSpec.describe Magick::Draw, '#scale' do
  before do
    @draw = Magick::Draw.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    @draw.scale('0.5', 1.5)
    expect(@draw.inspect).to eq('scale 0.5,1.5')
    @draw.rectangle(10, '10', 100, 100)
    expect { @draw.draw(@img) }.not_to raise_error

    expect { @draw.scale('x', 1.5) }.to raise_error(ArgumentError)
    expect { @draw.scale(0.5, 'x') }.to raise_error(ArgumentError)
  end
end

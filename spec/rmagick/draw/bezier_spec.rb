RSpec.describe Magick::Draw, '#bezier' do
  before do
    @draw = Magick::Draw.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    @draw.bezier(10, '20', '20.5', 30, 40.5, 50)
    expect(@draw.inspect).to eq('bezier 10,20,20.5,30,40.5,50')
    expect { @draw.draw(@img) }.not_to raise_error

    expect { @draw.bezier }.to raise_error(ArgumentError)
    expect { @draw.bezier(1) }.to raise_error(ArgumentError)
    expect { @draw.bezier('x', 20, 30, 40.5) }.to raise_error(ArgumentError)
  end
end

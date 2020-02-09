RSpec.describe Magick::Draw, '#rectangle' do
  before do
    @draw = described_class.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    @draw.rectangle(10, '10', 100, 100)
    expect(@draw.inspect).to eq('rectangle 10,10 100,100')
    expect { @draw.draw(@img) }.not_to raise_error

    expect { @draw.rectangle('x', 10, 20, 20) }.to raise_error(ArgumentError)
    expect { @draw.rectangle(10, 'x', 20, 20) }.to raise_error(ArgumentError)
    expect { @draw.rectangle(10, 10, 'x', 20) }.to raise_error(ArgumentError)
    expect { @draw.rectangle(10, 10, 20, 'x') }.to raise_error(ArgumentError)
  end
end

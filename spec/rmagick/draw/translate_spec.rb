RSpec.describe Magick::Draw, '#translate' do
  before do
    @draw = described_class.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    @draw.translate('200', 300)
    expect(@draw.inspect).to eq('translate 200,300')
    expect { @draw.draw(@img) }.not_to raise_error

    expect { @draw.translate('x', 300) }.to raise_error(ArgumentError)
    expect { @draw.translate(200, 'x') }.to raise_error(ArgumentError)
  end
end

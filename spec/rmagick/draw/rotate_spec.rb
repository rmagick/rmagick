RSpec.describe Magick::Draw, '#rotate' do
  before do
    @draw = described_class.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    @draw.rotate(45)
    expect(@draw.inspect).to eq('rotate 45')
    @draw.text(50, 50, 'Hello world')
    expect { @draw.draw(@img) }.not_to raise_error

    expect { @draw.rotate('x') }.to raise_error(ArgumentError)
  end
end

RSpec.describe Magick::Draw, '#encoding' do
  before do
    @draw = Magick::Draw.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    @draw.encoding('UTF-8')
    expect(@draw.inspect).to eq('encoding UTF-8')
    expect { @draw.draw(@img) }.not_to raise_error
  end
end

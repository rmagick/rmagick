RSpec.describe Magick::Draw, '#path' do
  before do
    @draw = Magick::Draw.new
    @img = Magick::Image.new(200, 200)
  end

  it 'works' do
    @draw.path('M110,100 h-75 a75,75 0 1,0 75,-75 z')
    expect(@draw.inspect).to eq("path 'M110,100 h-75 a75,75 0 1,0 75,-75 z'")
    expect { @draw.draw(@img) }.not_to raise_error
  end
end

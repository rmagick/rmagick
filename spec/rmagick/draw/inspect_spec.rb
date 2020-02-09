RSpec.describe Magick::Draw, '#inspect' do
  before do
    @draw = described_class.new
  end

  it 'works' do
    expect(@draw.inspect).to eq('(no primitives defined)')

    @draw.path('M110,100 h-75 a75,75 0 1,0 75,-75 z')
    @draw.fill('yellow')
    expect(@draw.inspect).to eq("path 'M110,100 h-75 a75,75 0 1,0 75,-75 z'\nfill \"yellow\"")
  end
end

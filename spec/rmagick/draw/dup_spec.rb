RSpec.describe Magick::Draw, '#dup' do
  before do
    @draw = Magick::Draw.new
  end

  it 'works' do
    @draw.path('M110,100 h-75 a75,75 0 1,0 75,-75 z')
    @draw.freeze
    dup = @draw.dup
    expect(dup).to be_instance_of(Magick::Draw)
  end
end

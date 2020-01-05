RSpec.describe Magick::AlignType, '#inspect' do
  it 'works' do
    expect(Magick::AlignType.values[0].inspect).to eq('UndefinedAlign=0')
  end
end

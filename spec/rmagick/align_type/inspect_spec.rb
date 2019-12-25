RSpec.describe Magick::Enum, '#inspect' do
  it 'works' do
    expect(Magick::AlignType.values[0].inspect).to eq('UndefinedAlign=0')
  end
end

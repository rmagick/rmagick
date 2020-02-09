RSpec.describe Magick::AlignType, '#inspect' do
  it 'works' do
    expect(described_class.values[0].inspect).to eq('UndefinedAlign=0')
  end
end

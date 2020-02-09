RSpec.describe Magick::AlignType, '.values' do
  it 'works' do
    expect(described_class.values).to be_instance_of(Array)

    expect(described_class.values[0].to_s).to eq('UndefinedAlign')
    expect(described_class.values[0].to_i).to eq(0)

    described_class.values do |enum|
      expect(enum).to be_kind_of(Magick::Enum)
      expect(enum).to be_instance_of(described_class)
    end
  end
end

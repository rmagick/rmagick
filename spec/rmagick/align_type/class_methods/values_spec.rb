RSpec.describe Magick::AlignType, '.values' do
  it 'works' do
    expect(Magick::AlignType.values).to be_instance_of(Array)

    expect(Magick::AlignType.values[0].to_s).to eq('UndefinedAlign')
    expect(Magick::AlignType.values[0].to_i).to eq(0)

    Magick::AlignType.values do |enum|
      expect(enum).to be_kind_of(Magick::Enum)
      expect(enum).to be_instance_of(Magick::AlignType)
    end
  end
end

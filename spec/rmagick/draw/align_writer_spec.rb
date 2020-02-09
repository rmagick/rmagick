RSpec.describe Magick::Draw, '#align=' do
  before do
    @draw = described_class.new
  end

  it 'works' do
    Magick::AlignType.values do |align|
      expect { @draw.align = align }.not_to raise_error
    end
  end
end

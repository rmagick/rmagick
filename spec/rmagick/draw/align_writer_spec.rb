RSpec.describe Magick::Draw, '#align=' do
  it 'works' do
    draw = described_class.new

    Magick::AlignType.values do |align|
      expect { draw.align = align }.not_to raise_error
    end
  end
end

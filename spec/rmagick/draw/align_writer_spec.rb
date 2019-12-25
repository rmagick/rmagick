RSpec.describe Magick::Draw, '#align=' do
  before do
    @draw = Magick::Draw.new
  end

  it 'works' do
    Magick::AlignType.values do |align|
      expect { @draw.align = align }.not_to raise_error
    end
  end
end

RSpec.describe Magick::Draw, '#text_antialias=' do
  before do
    @draw = described_class.new
  end

  it 'works' do
    expect { @draw.text_antialias = true }.not_to raise_error
    expect { @draw.text_antialias = false }.not_to raise_error
  end
end

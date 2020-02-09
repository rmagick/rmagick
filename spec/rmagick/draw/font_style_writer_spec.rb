RSpec.describe Magick::Draw, '#font_style=' do
  before do
    @draw = described_class.new
  end

  it 'works' do
    Magick::StyleType.values do |style|
      expect { @draw.font_style = style }.not_to raise_error
    end

    expect { @draw.font_style = 2 }.to raise_error(TypeError)
  end
end

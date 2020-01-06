RSpec.describe Magick::Draw, '#font_style=' do
  it 'works' do
    draw = described_class.new

    Magick::StyleType.values do |style|
      expect { draw.font_style = style }.not_to raise_error
    end

    expect { draw.font_style = 2 }.to raise_error(TypeError)
  end
end

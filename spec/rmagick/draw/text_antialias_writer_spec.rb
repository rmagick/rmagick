RSpec.describe Magick::Draw, '#text_antialias=' do
  it 'works' do
    draw = described_class.new

    expect { draw.text_antialias = true }.not_to raise_error
    expect { draw.text_antialias = false }.not_to raise_error
  end
end

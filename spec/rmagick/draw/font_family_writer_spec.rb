RSpec.describe Magick::Draw, '#font_family=' do
  it 'works' do
    draw = described_class.new

    expect { draw.font_family = 'Arial' }.not_to raise_error
    expect { draw.font_family = 2 }.to raise_error(TypeError)
  end
end

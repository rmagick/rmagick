RSpec.describe Magick::Draw, '#font=' do
  it 'works' do
    draw = described_class.new

    expect { draw.font = 'Arial-Bold' }.not_to raise_error
    expect { draw.font = 2 }.to raise_error(TypeError)
  end
end

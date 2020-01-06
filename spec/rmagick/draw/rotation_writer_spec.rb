RSpec.describe Magick::Draw, '#rotation=' do
  it 'works' do
    draw = described_class.new

    expect { draw.rotation = 15 }.not_to raise_error
    expect { draw.rotation = 'x' }.to raise_error(TypeError)
  end
end

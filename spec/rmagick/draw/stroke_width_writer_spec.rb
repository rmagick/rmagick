RSpec.describe Magick::Draw, '#stroke_width=' do
  it 'works' do
    draw = described_class.new

    expect { draw.stroke_width = 15 }.not_to raise_error
    expect { draw.stroke_width = 'x' }.to raise_error(TypeError)
  end
end

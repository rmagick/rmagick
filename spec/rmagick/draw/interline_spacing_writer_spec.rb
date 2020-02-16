RSpec.describe Magick::Draw, '#interline_spacing=' do
  it 'assigns without raising an error' do
    draw = described_class.new

    expect { draw.interline_spacing = 1 }.not_to raise_error
  end

  it 'works' do
    draw = described_class.new

    expect { draw.interline_spacing = 2 }.not_to raise_error
    expect { draw.interline_spacing = 'x' }.to raise_error(TypeError)
  end
end

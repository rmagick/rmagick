RSpec.describe Magick::Draw, '#interline_spacing=' do
  let(:draw) { described_class.new }

  it 'assigns without raising an error' do
    expect { draw.interline_spacing = 1 }.not_to raise_error
  end

  it 'works' do
    expect { draw.interline_spacing = 2 }.not_to raise_error
    expect { draw.interline_spacing = 'x' }.to raise_error(TypeError)
  end
end

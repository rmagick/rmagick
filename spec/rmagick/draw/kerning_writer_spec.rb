RSpec.describe Magick::Draw, '#kerning=' do
  let(:draw) { described_class.new }

  it 'assigns without raising an error' do
    expect { draw.kerning = 1 }.not_to raise_error
  end

  it 'works' do
    expect { draw.kerning = 2 }.not_to raise_error
    expect { draw.kerning = 'x' }.to raise_error(TypeError)
  end
end

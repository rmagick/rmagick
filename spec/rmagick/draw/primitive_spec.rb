RSpec.describe Magick::Draw, '#primitive' do
  it 'works' do
    draw = described_class.new

    expect { draw.primitive('ABCDEF') }.not_to raise_error
    expect { draw.primitive('12345') }.not_to raise_error
    expect { draw.primitive(nil) }.to raise_error(TypeError)
  end
end

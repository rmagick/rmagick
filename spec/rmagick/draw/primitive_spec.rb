RSpec.describe Magick::Draw, '#primitive' do
  before do
    @draw = described_class.new
  end

  it 'works' do
    expect { @draw.primitive('ABCDEF') }.not_to raise_error
    expect { @draw.primitive('12345') }.not_to raise_error
    expect { @draw.primitive(nil) }.to raise_error(TypeError)
  end
end

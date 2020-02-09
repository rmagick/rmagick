RSpec.describe Magick::Draw, '#rotation=' do
  before do
    @draw = described_class.new
  end

  it 'works' do
    expect { @draw.rotation = 15 }.not_to raise_error
    expect { @draw.rotation = 'x' }.to raise_error(TypeError)
  end
end

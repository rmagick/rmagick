RSpec.describe Magick::Draw, '#font=' do
  before do
    @draw = described_class.new
  end

  it 'works' do
    expect { @draw.font = 'Arial-Bold' }.not_to raise_error
    expect { @draw.font = 2 }.to raise_error(TypeError)
  end
end

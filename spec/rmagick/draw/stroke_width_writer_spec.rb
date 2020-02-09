RSpec.describe Magick::Draw, '#stroke_width=' do
  before do
    @draw = described_class.new
  end

  it 'works' do
    expect { @draw.stroke_width = 15 }.not_to raise_error
    expect { @draw.stroke_width = 'x' }.to raise_error(TypeError)
  end
end

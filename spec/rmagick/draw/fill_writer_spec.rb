RSpec.describe Magick::Draw, '#fill=' do
  before do
    @draw = described_class.new
  end

  it 'works' do
    expect { @draw.fill = 'white' }.not_to raise_error
    expect { @draw.fill = Magick::Pixel.from_color('white') }.not_to raise_error
    expect { @draw.fill = 2 }.to raise_error(TypeError)
  end
end

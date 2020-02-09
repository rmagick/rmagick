RSpec.describe Magick::Draw, '#stroke=' do
  before do
    @draw = described_class.new
  end

  it 'works' do
    expect { @draw.stroke = Magick::Pixel.from_color('white') }.not_to raise_error
    expect { @draw.stroke = 'white' }.not_to raise_error
    expect { @draw.stroke = 2 }.to raise_error(TypeError)
  end
end

RSpec.describe Magick::Draw, '#undercolor=' do
  before do
    @draw = described_class.new
  end

  it 'works' do
    expect { @draw.undercolor = Magick::Pixel.from_color('white') }.not_to raise_error
    expect { @draw.undercolor = 'white' }.not_to raise_error
    expect { @draw.undercolor = 2 }.to raise_error(TypeError)
  end
end

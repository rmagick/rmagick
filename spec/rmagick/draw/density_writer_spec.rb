RSpec.describe Magick::Draw, '#density=' do
  before do
    @draw = Magick::Draw.new
  end

  it 'works' do
    expect { @draw.density = '90x90' }.not_to raise_error
    expect { @draw.density = 'x90' }.not_to raise_error
    expect { @draw.density = '90' }.not_to raise_error
    expect { @draw.density = 2 }.to raise_error(TypeError)
  end
end

RSpec.describe Magick::Image, '#density' do
  before do
    @img = described_class.new(100, 100)
  end

  it 'works' do
    expect { @img.density }.not_to raise_error
    expect { @img.density = '90x90' }.not_to raise_error
    expect { @img.density = 'x90' }.not_to raise_error
    expect { @img.density = '90' }.not_to raise_error
    expect { @img.density = Magick::Geometry.new(@img.columns / 2, @img.rows / 2, 5, 5) }.not_to raise_error
    expect { @img.density = 2 }.to raise_error(TypeError)
  end
end

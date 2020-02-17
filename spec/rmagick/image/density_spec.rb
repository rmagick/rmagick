RSpec.describe Magick::Image, '#density' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.density }.not_to raise_error
    expect { image.density = '90x90' }.not_to raise_error
    expect { image.density = 'x90' }.not_to raise_error
    expect { image.density = '90' }.not_to raise_error
    expect { image.density = Magick::Geometry.new(image.columns / 2, image.rows / 2, 5, 5) }.not_to raise_error
    expect { image.density = 2 }.to raise_error(TypeError)
  end
end

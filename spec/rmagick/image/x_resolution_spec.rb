RSpec.describe Magick::Image, '#x_resolution' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.x_resolution }.not_to raise_error
    expect { image.x_resolution = 90 }.not_to raise_error
    expect(image.x_resolution).to eq(90.0)
    expect { image.x_resolution = 'x' }.to raise_error(TypeError)
  end
end

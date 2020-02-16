RSpec.describe Magick::Image, '#x_resolution' do
  it 'works' do
    img = described_class.new(100, 100)

    expect { img.x_resolution }.not_to raise_error
    expect { img.x_resolution = 90 }.not_to raise_error
    expect(img.x_resolution).to eq(90.0)
    expect { img.x_resolution = 'x' }.to raise_error(TypeError)
  end
end

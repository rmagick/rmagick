RSpec.describe Magick::Image, '#y_resolution' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.y_resolution }.not_to raise_error
    expect { image.y_resolution = 90 }.not_to raise_error
    expect(image.y_resolution).to eq(90.0)
    expect { image.y_resolution = 'x' }.to raise_error(TypeError)
  end
end

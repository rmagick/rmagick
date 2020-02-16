RSpec.describe Magick::Image, '#y_resolution' do
  it 'works' do
    img = described_class.new(100, 100)

    expect { img.y_resolution }.not_to raise_error
    expect { img.y_resolution = 90 }.not_to raise_error
    expect(img.y_resolution).to eq(90.0)
    expect { img.y_resolution = 'x' }.to raise_error(TypeError)
  end
end

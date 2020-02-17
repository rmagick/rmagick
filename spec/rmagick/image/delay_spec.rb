RSpec.describe Magick::Image, '#delay' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.delay }.not_to raise_error
    expect(image.delay).to eq(0)
    expect { image.delay = 10 }.not_to raise_error
    expect(image.delay).to eq(10)
    expect { image.delay = 'x' }.to raise_error(TypeError)
  end
end

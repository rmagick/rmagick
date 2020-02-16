RSpec.describe Magick::Image, '#delay' do
  it 'works' do
    img = described_class.new(100, 100)

    expect { img.delay }.not_to raise_error
    expect(img.delay).to eq(0)
    expect { img.delay = 10 }.not_to raise_error
    expect(img.delay).to eq(10)
    expect { img.delay = 'x' }.to raise_error(TypeError)
  end
end

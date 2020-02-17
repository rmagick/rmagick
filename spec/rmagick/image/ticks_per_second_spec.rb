RSpec.describe Magick::Image, '#ticks_per_second' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.ticks_per_second }.not_to raise_error
    expect(image.ticks_per_second).to eq(100)
    expect { image.ticks_per_second = 1000 }.not_to raise_error
    expect(image.ticks_per_second).to eq(1000)
    expect { image.ticks_per_second = 'x' }.to raise_error(TypeError)
  end
end

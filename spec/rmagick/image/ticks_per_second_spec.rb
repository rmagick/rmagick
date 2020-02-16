RSpec.describe Magick::Image, '#ticks_per_second' do
  it 'works' do
    img = described_class.new(100, 100)

    expect { img.ticks_per_second }.not_to raise_error
    expect(img.ticks_per_second).to eq(100)
    expect { img.ticks_per_second = 1000 }.not_to raise_error
    expect(img.ticks_per_second).to eq(1000)
    expect { img.ticks_per_second = 'x' }.to raise_error(TypeError)
  end
end

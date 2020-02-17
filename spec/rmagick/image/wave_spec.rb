RSpec.describe Magick::Image, '#wave' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.wave
    expect(result).to be_instance_of(described_class)

    expect { image.wave(25) }.not_to raise_error
    expect { image.wave(25, 200) }.not_to raise_error
    expect { image.wave(25, 200, 2) }.to raise_error(ArgumentError)
    expect { image.wave('x') }.to raise_error(TypeError)
    expect { image.wave(25, 'x') }.to raise_error(TypeError)
  end
end

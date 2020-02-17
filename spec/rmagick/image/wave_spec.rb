RSpec.describe Magick::Image, '#wave' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.wave
    expect(res).to be_instance_of(described_class)

    expect { img.wave(25) }.not_to raise_error
    expect { img.wave(25, 200) }.not_to raise_error
    expect { img.wave(25, 200, 2) }.to raise_error(ArgumentError)
    expect { img.wave('x') }.to raise_error(TypeError)
    expect { img.wave(25, 'x') }.to raise_error(TypeError)
  end
end

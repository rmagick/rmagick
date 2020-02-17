RSpec.describe Magick::Image, '#sample' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.sample(10, 10)
    expect(res).to be_instance_of(described_class)

    expect { image.sample(2) }.not_to raise_error
    expect { image.sample }.to raise_error(ArgumentError)
    expect { image.sample(0) }.to raise_error(ArgumentError)
    expect { image.sample(0, 25) }.to raise_error(ArgumentError)
    expect { image.sample(25, 0) }.to raise_error(ArgumentError)
    expect { image.sample(25, 25, 25) }.to raise_error(ArgumentError)
    expect { image.sample('x') }.to raise_error(TypeError)
    expect { image.sample(10, 'x') }.to raise_error(TypeError)
  end
end

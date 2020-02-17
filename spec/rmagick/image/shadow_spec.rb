RSpec.describe Magick::Image, '#shadow' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.shadow
    expect(res).to be_instance_of(described_class)

    expect { image.shadow(5) }.not_to raise_error
    expect { image.shadow(5, 5) }.not_to raise_error
    expect { image.shadow(5, 5, 3.0) }.not_to raise_error
    expect { image.shadow(5, 5, 3.0, 0.50) }.not_to raise_error
    expect { image.shadow(5, 5, 3.0, '50%') }.not_to raise_error
    expect { image.shadow(5, 5, 3.0, 0.50, 2) }.to raise_error(ArgumentError)
    expect { image.shadow('x') }.to raise_error(TypeError)
    expect { image.shadow(5, 'x') }.to raise_error(TypeError)
    expect { image.shadow(5, 5, 'x') }.to raise_error(TypeError)
    expect { image.shadow(5, 5, 3.0, 'x') }.to raise_error(ArgumentError)
  end
end

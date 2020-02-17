RSpec.describe Magick::Image, '#raise' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.raise
    expect(result).to be_instance_of(described_class)

    expect { image.raise(4) }.not_to raise_error
    expect { image.raise(4, 4) }.not_to raise_error
    expect { image.raise(4, 4, false) }.not_to raise_error
    expect { image.raise('x') }.to raise_error(TypeError)
    expect { image.raise(2, 'x') }.to raise_error(TypeError)
    expect { image.raise(4, 4, false, 2) }.to raise_error(ArgumentError)
  end
end

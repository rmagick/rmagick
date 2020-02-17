RSpec.describe Magick::Image, '#sharpen' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.sharpen
    expect(result).to be_instance_of(described_class)

    expect { image.sharpen(2.0) }.not_to raise_error
    expect { image.sharpen(2.0, 1.0) }.not_to raise_error
    expect { image.sharpen(2.0, 1.0, 2) }.to raise_error(ArgumentError)
    expect { image.sharpen('x') }.to raise_error(TypeError)
    expect { image.sharpen(2.0, 'x') }.to raise_error(TypeError)
  end
end

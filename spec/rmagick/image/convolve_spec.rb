RSpec.describe Magick::Image, '#convolve' do
  it 'works' do
    image = described_class.new(20, 20)
    kernel = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
    order = 3

    res = image.convolve(order, kernel)
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(image)

    expect { image.convolve }.to raise_error(ArgumentError)
    expect { image.convolve(0) }.to raise_error(ArgumentError)
    expect { image.convolve(-1) }.to raise_error(ArgumentError)
    expect { image.convolve(order) }.to raise_error(ArgumentError)
    expect { image.convolve(5, kernel) }.to raise_error(IndexError)
    expect { image.convolve(order, 'x') }.to raise_error(IndexError)
    expect { image.convolve(3, [1.0, 1.0, 1.0, 1.0, 'x', 1.0, 1.0, 1.0, 1.0]) }.to raise_error(TypeError)
    expect { image.convolve(-1, [1.0, 1.0, 1.0, 1.0]) }.to raise_error(ArgumentError)
  end
end

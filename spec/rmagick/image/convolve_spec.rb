RSpec.describe Magick::Image, '#convolve' do
  it 'works' do
    img = described_class.new(20, 20)
    kernel = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
    order = 3

    res = img.convolve(order, kernel)
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(img)

    expect { img.convolve }.to raise_error(ArgumentError)
    expect { img.convolve(0) }.to raise_error(ArgumentError)
    expect { img.convolve(-1) }.to raise_error(ArgumentError)
    expect { img.convolve(order) }.to raise_error(ArgumentError)
    expect { img.convolve(5, kernel) }.to raise_error(IndexError)
    expect { img.convolve(order, 'x') }.to raise_error(IndexError)
    expect { img.convolve(3, [1.0, 1.0, 1.0, 1.0, 'x', 1.0, 1.0, 1.0, 1.0]) }.to raise_error(TypeError)
    expect { img.convolve(-1, [1.0, 1.0, 1.0, 1.0]) }.to raise_error(ArgumentError)
  end
end

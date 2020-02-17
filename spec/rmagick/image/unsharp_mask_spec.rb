RSpec.describe Magick::Image, '#unsharp_mask' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.unsharp_mask
    expect(res).to be_instance_of(described_class)

    expect { img.unsharp_mask(2.0) }.not_to raise_error
    expect { img.unsharp_mask(2.0, 1.0) }.not_to raise_error
    expect { img.unsharp_mask(2.0, 1.0, 0.50) }.not_to raise_error
    expect { img.unsharp_mask(2.0, 1.0, 0.50, 0.10) }.not_to raise_error
    expect { img.unsharp_mask(2.0, 1.0, 0.50, 0.10, 2) }.to raise_error(ArgumentError)
    expect { img.unsharp_mask(-2.0, 1.0, 0.50, 0.10) }.to raise_error(ArgumentError)
    expect { img.unsharp_mask(2.0, 0.0, 0.50, 0.10) }.to raise_error(ArgumentError)
    expect { img.unsharp_mask(2.0, 1.0, 0.0, 0.10) }.to raise_error(ArgumentError)
    expect { img.unsharp_mask(2.0, 1.0, 0.01, -0.10) }.to raise_error(ArgumentError)
    expect { img.unsharp_mask('x') }.to raise_error(TypeError)
    expect { img.unsharp_mask(2.0, 'x') }.to raise_error(TypeError)
    expect { img.unsharp_mask(2.0, 1.0, 'x') }.to raise_error(TypeError)
    expect { img.unsharp_mask(2.0, 1.0, 0.50, 'x') }.to raise_error(TypeError)
  end
end

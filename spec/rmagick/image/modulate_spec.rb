RSpec.describe Magick::Image, '#modulate' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.modulate
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    expect { image.modulate(0.5) }.not_to raise_error
    expect { image.modulate('50%') }.not_to raise_error
    expect { image.modulate(0.5, 0.5) }.not_to raise_error
    expect { image.modulate(0.5, '50%') }.not_to raise_error
    expect { image.modulate(0.5, 0.5, 0.5) }.not_to raise_error
    expect { image.modulate(0.5, 0.5, '50%') }.not_to raise_error
    expect { image.modulate(0.0, 0.5, 0.5) }.to raise_error(ArgumentError)
    expect { image.modulate(0.5, 0.5, 0.5, 0.5) }.to raise_error(ArgumentError)
    expect { image.modulate('x', 0.5, 0.5) }.to raise_error(ArgumentError)
    expect { image.modulate(0.5, 'x', 0.5) }.to raise_error(ArgumentError)
    expect { image.modulate(0.5, 0.5, 'x') }.to raise_error(ArgumentError)
  end
end

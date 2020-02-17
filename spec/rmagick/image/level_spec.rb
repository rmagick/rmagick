RSpec.describe Magick::Image, '#level' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.level
    expect(res).to be_instance_of(described_class)
    expect(res).not_to be(image)

    expect { image.level(0.0) }.not_to raise_error
    expect { image.level(0.0, 1.0) }.not_to raise_error
    expect { image.level(0.0, 1.0, Magick::QuantumRange) }.not_to raise_error
    expect { image.level(0.0, 1.0, Magick::QuantumRange, 2) }.to raise_error(ArgumentError)
    expect { image.level('x') }.to raise_error(ArgumentError)
    expect { image.level(0.0, 'x') }.to raise_error(ArgumentError)
    expect { image.level(0.0, 1.0, 'x') }.to raise_error(ArgumentError)
  end
end

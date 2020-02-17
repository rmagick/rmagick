RSpec.describe Magick::Image, '#bias' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.bias }.not_to raise_error
    expect(image.bias).to eq(0.0)
    expect(image.bias).to be_instance_of(Float)

    expect { image.bias = 0.1 }.not_to raise_error
    expect(image.bias).to be_within(0.1).of(Magick::QuantumRange * 0.1)

    expect { image.bias = '10%' }.not_to raise_error
    expect(image.bias).to be_within(0.1).of(Magick::QuantumRange * 0.10)

    expect { image.bias = [] }.to raise_error(TypeError)
    expect { image.bias = 'x' }.to raise_error(ArgumentError)
  end
end

RSpec.describe Magick::Image, '#solarize' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.solarize
    expect(res).to be_instance_of(described_class)

    expect { image.solarize(100) }.not_to raise_error
    expect { image.solarize(-100) }.to raise_error(ArgumentError)
    expect { image.solarize(Magick::QuantumRange + 1) }.to raise_error(ArgumentError)
    expect { image.solarize(100, 2) }.to raise_error(ArgumentError)
    expect { image.solarize('x') }.to raise_error(TypeError)
  end
end

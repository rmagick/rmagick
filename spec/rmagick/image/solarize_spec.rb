RSpec.describe Magick::Image, '#solarize' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.solarize
    expect(res).to be_instance_of(described_class)

    expect { img.solarize(100) }.not_to raise_error
    expect { img.solarize(-100) }.to raise_error(ArgumentError)
    expect { img.solarize(Magick::QuantumRange + 1) }.to raise_error(ArgumentError)
    expect { img.solarize(100, 2) }.to raise_error(ArgumentError)
    expect { img.solarize('x') }.to raise_error(TypeError)
  end
end

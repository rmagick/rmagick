RSpec.describe Magick::Image, '#bias' do
  before do
    @img = described_class.new(100, 100)
  end

  it 'works' do
    expect { @img.bias }.not_to raise_error
    expect(@img.bias).to eq(0.0)
    expect(@img.bias).to be_instance_of(Float)

    expect { @img.bias = 0.1 }.not_to raise_error
    expect(@img.bias).to be_within(0.1).of(Magick::QuantumRange * 0.1)

    expect { @img.bias = '10%' }.not_to raise_error
    expect(@img.bias).to be_within(0.1).of(Magick::QuantumRange * 0.10)

    expect { @img.bias = [] }.to raise_error(TypeError)
    expect { @img.bias = 'x' }.to raise_error(ArgumentError)
  end
end

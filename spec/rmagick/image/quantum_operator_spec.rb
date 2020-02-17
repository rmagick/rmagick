RSpec.describe Magick::Image, '#quantum_operator' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.quantum_operator(Magick::AddQuantumOperator, 2)
    expect(res).to be_instance_of(described_class)

    Magick::QuantumExpressionOperator.values do |op|
      expect { image.quantum_operator(op, 2) }.not_to raise_error
    end
    expect { image.quantum_operator(Magick::AddQuantumOperator, 2, Magick::RedChannel) }.not_to raise_error
    expect { image.quantum_operator(2, 2) }.to raise_error(TypeError)
    expect { image.quantum_operator(Magick::AddQuantumOperator, 'x') }.to raise_error(TypeError)
    expect { image.quantum_operator(Magick::AddQuantumOperator, 2, 2) }.to raise_error(TypeError)
    expect { image.quantum_operator(Magick::AddQuantumOperator, 2, Magick::RedChannel, 2) }.to raise_error(ArgumentError)
  end
end

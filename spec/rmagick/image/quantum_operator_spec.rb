RSpec.describe Magick::Image, '#quantum_operator' do
  it 'works' do
    img = described_class.new(20, 20)

    expect do
      res = img.quantum_operator(Magick::AddQuantumOperator, 2)
      expect(res).to be_instance_of(described_class)
    end.not_to raise_error
    Magick::QuantumExpressionOperator.values do |op|
      expect { img.quantum_operator(op, 2) }.not_to raise_error
    end
    expect { img.quantum_operator(Magick::AddQuantumOperator, 2, Magick::RedChannel) }.not_to raise_error
    expect { img.quantum_operator(2, 2) }.to raise_error(TypeError)
    expect { img.quantum_operator(Magick::AddQuantumOperator, 'x') }.to raise_error(TypeError)
    expect { img.quantum_operator(Magick::AddQuantumOperator, 2, 2) }.to raise_error(TypeError)
    expect { img.quantum_operator(Magick::AddQuantumOperator, 2, Magick::RedChannel, 2) }.to raise_error(ArgumentError)
  end
end

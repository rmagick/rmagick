RSpec.describe Magick::Image, '#sepiatone' do
  it 'works' do
    image = described_class.new(20, 20)

    res = image.sepiatone
    expect(res).to be_instance_of(described_class)

    expect { image.sepiatone(Magick::QuantumRange * 0.80) }.not_to raise_error
    expect { image.sepiatone(Magick::QuantumRange, 2) }.to raise_error(ArgumentError)
    expect { image.sepiatone('x') }.to raise_error(TypeError)
  end
end

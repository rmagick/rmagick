RSpec.describe Magick::Image, '#sepiatone' do
  it 'works' do
    img = described_class.new(20, 20)

    res = img.sepiatone
    expect(res).to be_instance_of(described_class)

    expect { img.sepiatone(Magick::QuantumRange * 0.80) }.not_to raise_error
    expect { img.sepiatone(Magick::QuantumRange, 2) }.to raise_error(ArgumentError)
    expect { img.sepiatone('x') }.to raise_error(TypeError)
  end
end

RSpec.describe Magick::Image, '#quantum_depth' do
  it 'works' do
    image = described_class.new(100, 100)

    expect { image.quantum_depth }.not_to raise_error
    expect(image.quantum_depth).to eq(Magick::MAGICKCORE_QUANTUM_DEPTH)
    expect { image.quantum_depth = 8 }.to raise_error(NoMethodError)
  end
end

RSpec.describe Magick::Image, '#quantum_depth' do
  it 'works' do
    img = described_class.new(100, 100)

    expect { img.quantum_depth }.not_to raise_error
    expect(img.quantum_depth).to eq(Magick::MAGICKCORE_QUANTUM_DEPTH)
    expect { img.quantum_depth = 8 }.to raise_error(NoMethodError)
  end
end

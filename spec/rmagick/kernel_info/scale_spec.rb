RSpec.describe Magick::KernelInfo, '#scale' do
  it 'works' do
    kernel = described_class.new('Octagon')

    Magick::GeometryFlags.values do |flag|
      expect(kernel.scale(1.0, flag)).to be(nil)
      expect(kernel.scale(42, flag)).to be(nil)
    end
    expect { kernel.scale(42, 'x') }.to raise_error(ArgumentError)
    expect { kernel.scale(42, Magick::BoldWeight) }.to raise_error(ArgumentError)
  end
end

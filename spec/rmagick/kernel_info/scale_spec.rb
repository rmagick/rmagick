RSpec.describe Magick::KernelInfo, '#scale' do
  before do
    @kernel = Magick::KernelInfo.new('Octagon')
  end

  it 'works' do
    Magick::GeometryFlags.values do |flag|
      expect(@kernel.scale(1.0, flag)).to be(nil)
      expect(@kernel.scale(42, flag)).to be(nil)
    end
    expect { @kernel.scale(42, 'x') }.to raise_error(ArgumentError)
    expect { @kernel.scale(42, Magick::BoldWeight) }.to raise_error(ArgumentError)
  end
end

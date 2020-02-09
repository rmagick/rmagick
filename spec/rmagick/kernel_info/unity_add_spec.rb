RSpec.describe Magick::KernelInfo, '#unity_add' do
  before do
    @kernel = described_class.new('Octagon')
  end

  it 'works' do
    expect(@kernel.unity_add(1.0)).to be(nil)
    expect(@kernel.unity_add(12)).to be(nil)
    expect { @kernel.unity_add('x') }.to raise_error(TypeError)
  end
end

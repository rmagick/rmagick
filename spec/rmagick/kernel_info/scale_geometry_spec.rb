RSpec.describe Magick::KernelInfo, '#scale_geometry' do
  before do
    @kernel = Magick::KernelInfo.new('Octagon')
  end

  it 'works' do
    expect(@kernel.scale_geometry('-set option:convolve:scale 1.0')).to be(nil)
    expect { @kernel.scale_geometry(42) }.to raise_error(TypeError)
  end
end

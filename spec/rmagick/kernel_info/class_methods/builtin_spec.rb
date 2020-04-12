RSpec.describe Magick::KernelInfo, '.builtin' do
  it 'works', unsupported_before('6.9.0') do
    expect(described_class.builtin(Magick::UnityKernel, '')).to be_instance_of(described_class)
    expect(described_class.builtin(Magick::GaussianKernel, 'Gaussian:10,5')).to be_instance_of(described_class)
    expect(described_class.builtin(Magick::LoGKernel, 'LoG:10,5')).to be_instance_of(described_class)
    expect(described_class.builtin(Magick::DoGKernel, 'DoG:10,5')).to be_instance_of(described_class)
    expect(described_class.builtin(Magick::BlurKernel, 'Blur:10,5,1')).to be_instance_of(described_class)
    expect(described_class.builtin(Magick::CometKernel, 'Comet:10,5,1')).to be_instance_of(described_class)
  end
end

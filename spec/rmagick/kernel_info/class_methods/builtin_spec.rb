RSpec.describe Magick::KernelInfo, '.builtin' do
  it 'works' do
    expect(Magick::KernelInfo.builtin(Magick::UnityKernel, '')).to be_instance_of(Magick::KernelInfo)
    expect(Magick::KernelInfo.builtin(Magick::GaussianKernel, 'Gaussian:10,5')).to be_instance_of(Magick::KernelInfo)
    expect(Magick::KernelInfo.builtin(Magick::LoGKernel, 'LoG:10,5')).to be_instance_of(Magick::KernelInfo)
    expect(Magick::KernelInfo.builtin(Magick::DoGKernel, 'DoG:10,5')).to be_instance_of(Magick::KernelInfo)
    expect(Magick::KernelInfo.builtin(Magick::BlurKernel, 'Blur:10,5,1')).to be_instance_of(Magick::KernelInfo)
    expect(Magick::KernelInfo.builtin(Magick::CometKernel, 'Comet:10,5,1')).to be_instance_of(Magick::KernelInfo)
  end
end

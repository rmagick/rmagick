RSpec.describe Magick::KernelInfo, '#initialize' do
  it 'works' do
    Magick::KernelInfoType.values do |kernel|
      k = kernel.to_s.sub('Kernel', '')

      if kernel == Magick::UserDefinedKernel
        expect { Magick::KernelInfo.new(k) }.to raise_error(RuntimeError)
      else
        expect(Magick::KernelInfo.new(k)).to be_instance_of(Magick::KernelInfo)
      end
    end
    expect { Magick::KernelInfo.new('') }.to raise_error(RuntimeError)
    expect { Magick::KernelInfo.new(42) }.to raise_error(TypeError)
  end
end

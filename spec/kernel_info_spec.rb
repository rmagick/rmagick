RSpec.describe Magick::KernelInfo do
  before do
    @kernel = Magick::KernelInfo.new('Octagon')
  end

  describe '#new' do
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

  describe '#unity_add' do
    it 'works' do
      expect(@kernel.unity_add(1.0)).to be(nil)
      expect(@kernel.unity_add(12)).to be(nil)
      expect { @kernel.unity_add('x') }.to raise_error(TypeError)
    end
  end

  describe '#scale' do
    it 'works' do
      Magick::GeometryFlags.values do |flag|
        expect(@kernel.scale(1.0, flag)).to be(nil)
        expect(@kernel.scale(42, flag)).to be(nil)
      end
      expect { @kernel.scale(42, 'x') }.to raise_error(ArgumentError)
      expect { @kernel.scale(42, Magick::BoldWeight) }.to raise_error(ArgumentError)
    end
  end

  describe '#scale_geometry' do
    it 'works' do
      expect(@kernel.scale_geometry('-set option:convolve:scale 1.0')).to be(nil)
      expect { @kernel.scale_geometry(42) }.to raise_error(TypeError)
    end
  end

  describe '#clone' do
    it 'works' do
      expect(@kernel.clone).to be_instance_of(Magick::KernelInfo)
      expect(@kernel.clone).not_to be(@kernel)
    end
  end

  describe '#builtin' do
    it 'works' do
      expect(Magick::KernelInfo.builtin(Magick::UnityKernel, '')).to be_instance_of(Magick::KernelInfo)
      expect(Magick::KernelInfo.builtin(Magick::GaussianKernel, 'Gaussian:10,5')).to be_instance_of(Magick::KernelInfo)
      expect(Magick::KernelInfo.builtin(Magick::LoGKernel, 'LoG:10,5')).to be_instance_of(Magick::KernelInfo)
      expect(Magick::KernelInfo.builtin(Magick::DoGKernel, 'DoG:10,5')).to be_instance_of(Magick::KernelInfo)
      expect(Magick::KernelInfo.builtin(Magick::BlurKernel, 'Blur:10,5,1')).to be_instance_of(Magick::KernelInfo)
      expect(Magick::KernelInfo.builtin(Magick::CometKernel, 'Comet:10,5,1')).to be_instance_of(Magick::KernelInfo)
    end
  end
end

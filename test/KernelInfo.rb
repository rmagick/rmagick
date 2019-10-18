require 'rmagick'
require 'minitest/autorun'

class KernelInfoUT < Minitest::Test
  def setup
    @kernel = Magick::KernelInfo.new('Octagon')
  end

  def test_new
    Magick::KernelInfoType.values do |kernel|
      k = kernel.to_s.sub('Kernel', '')

      if kernel == Magick::UserDefinedKernel
        expect { Magick::KernelInfo.new(k) }.to raise_error(RuntimeError)
      else
        assert_instance_of(Magick::KernelInfo, Magick::KernelInfo.new(k))
      end
    end
    expect { Magick::KernelInfo.new('') }.to raise_error(RuntimeError)
    expect { Magick::KernelInfo.new(42) }.to raise_error(TypeError)
  end

  def test_unity_add
    assert_nil(@kernel.unity_add(1.0))
    assert_nil(@kernel.unity_add(12))
    expect { @kernel.unity_add('x') }.to raise_error(TypeError)
  end

  def test_scale
    Magick::GeometryFlags.values do |flag|
      assert_nil(@kernel.scale(1.0, flag))
      assert_nil(@kernel.scale(42, flag))
    end
    expect { @kernel.scale(42, 'x') }.to raise_error(ArgumentError)
    expect { @kernel.scale(42, Magick::BoldWeight) }.to raise_error(ArgumentError)
  end

  def test_scale_geometry
    assert_nil(@kernel.scale_geometry('-set option:convolve:scale 1.0'))
    expect { @kernel.scale_geometry(42) }.to raise_error(TypeError)
  end

  def test_clone
    assert_instance_of(Magick::KernelInfo, @kernel.clone)
    assert_not_same(@kernel, @kernel.clone)
  end

  def test_builtin
    assert_instance_of(Magick::KernelInfo, Magick::KernelInfo.builtin(Magick::UnityKernel, ''))
    assert_instance_of(Magick::KernelInfo, Magick::KernelInfo.builtin(Magick::GaussianKernel, 'Gaussian:10,5'))
    assert_instance_of(Magick::KernelInfo, Magick::KernelInfo.builtin(Magick::LoGKernel, 'LoG:10,5'))
    assert_instance_of(Magick::KernelInfo, Magick::KernelInfo.builtin(Magick::DoGKernel, 'DoG:10,5'))
    assert_instance_of(Magick::KernelInfo, Magick::KernelInfo.builtin(Magick::BlurKernel, 'Blur:10,5,1'))
    assert_instance_of(Magick::KernelInfo, Magick::KernelInfo.builtin(Magick::CometKernel, 'Comet:10,5,1'))
  end
end

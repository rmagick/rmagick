# !/usr/bin/env ruby -w

require 'rmagick'
require 'test/unit'
require 'test/unit/ui/console/testrunner'

class KernelInfoUT < Test::Unit::TestCase
  setup do
    @kernel = Magick::KernelInfo.new('Octagon')
  end

  def test_new
    Magick::KernelInfoType.values do |kernel|
      k = kernel.to_s.sub('Kernel', '')

      if kernel == Magick::UserDefinedKernel
        assert_raise(RuntimeError) { Magick::KernelInfo.new(k) }
      else
        assert_instance_of(Magick::KernelInfo, Magick::KernelInfo.new(k))
      end
    end
    assert_raise(RuntimeError) { Magick::KernelInfo.new('') }
    assert_raise(TypeError) { Magick::KernelInfo.new(42) }
  end

  def test_unity_add
    assert_nil(@kernel.unity_add(1.0))
    assert_nil(@kernel.unity_add(12))
    assert_raise(TypeError) { @kernel.unity_add('x') }
  end

  def test_scale
    Magick::GeometryFlags.values do |flag|
      assert_nil(@kernel.scale(1.0, flag))
      assert_nil(@kernel.scale(42, flag))
    end
    assert_raise(ArgumentError) { @kernel.scale(42, 'x') }
    assert_raise(ArgumentError) { @kernel.scale(42, Magick::BoldWeight) }
  end

  def test_scale_geometry
    assert_nil(@kernel.scale_geometry('-set option:convolve:scale 1.0'))
    assert_raise(TypeError) { @kernel.scale_geometry(42) }
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

#!/usr/bin/env ruby -w

require 'rmagick'
require 'test/unit'
require 'test/unit/ui/console/testrunner'

class GradientFillUT < Test::Unit::TestCase
  def test_new
    assert_instance_of(Magick::GradientFill, Magick::GradientFill.new(0, 0, 0, 100, '#900', '#000'))
    assert_instance_of(Magick::GradientFill, Magick::GradientFill.new(0, 0, 0, 100, 'white', 'red'))

    assert_raise(ArgumentError) { Magick::GradientFill.new(0, 0, 0, 100, 'foo', '#000') }
    assert_raise(ArgumentError) { Magick::GradientFill.new(0, 0, 0, 100, '#900', 'bar') }
    assert_raise(TypeError) { Magick::GradientFill.new('x1', 0, 0, 100, '#900', '#000') }
    assert_raise(TypeError) { Magick::GradientFill.new(0, 'y1', 0, 100, '#900', '#000') }
    assert_raise(TypeError) { Magick::GradientFill.new(0, 0, 'x2', 100, '#900', '#000') }
    assert_raise(TypeError) { Magick::GradientFill.new(0, 0, 0, 'y2', '#900', '#000') }
  end

  def test_fill
    img = Magick::Image.new(10, 10)

    assert_nothing_raised do
      gradient = Magick::GradientFill.new(0, 0, 0, 0, '#900', '#000')
      obj = gradient.fill(img)
      assert_equal(gradient, obj)
    end

    assert_nothing_raised do
      gradient = Magick::GradientFill.new(0, 0, 0, 10, '#900', '#000')
      obj = gradient.fill(img)
      assert_equal(gradient, obj)
    end

    assert_nothing_raised do
      gradient = Magick::GradientFill.new(0, 0, 10, 0, '#900', '#000')
      obj = gradient.fill(img)
      assert_equal(gradient, obj)
    end

    assert_nothing_raised do
      gradient = Magick::GradientFill.new(0, 0, 10, 10, '#900', '#000')
      obj = gradient.fill(img)
      assert_equal(gradient, obj)
    end

    assert_nothing_raised do
      gradient = Magick::GradientFill.new(0, 0, 5, 20, '#900', '#000')
      obj = gradient.fill(img)
      assert_equal(gradient, obj)
    end

    assert_nothing_raised do
      gradient = Magick::GradientFill.new(-10, 0, -10, 10, '#900', '#000')
      obj = gradient.fill(img)
      assert_equal(gradient, obj)
    end

    assert_nothing_raised do
      gradient = Magick::GradientFill.new(0, -10, 10, -10, '#900', '#000')
      obj = gradient.fill(img)
      assert_equal(gradient, obj)
    end

    assert_nothing_raised do
      gradient = Magick::GradientFill.new(0, -10, 10, -20, '#900', '#000')
      obj = gradient.fill(img)
      assert_equal(gradient, obj)
    end

    assert_nothing_raised do
      gradient = Magick::GradientFill.new(0, 100, 100, 200, '#900', '#000')
      obj = gradient.fill(img)
      assert_equal(gradient, obj)
    end
  end
end

class TextureFillUT < Test::Unit::TestCase
  def test_new
    granite = Magick::Image.read('granite:').first
    assert_instance_of(Magick::TextureFill, Magick::TextureFill.new(granite))
  end

  def test_fill
    granite = Magick::Image.read('granite:').first
    texture = Magick::TextureFill.new(granite)

    img = Magick::Image.new(10, 10)
    obj = texture.fill(img)
    assert_equal(texture, obj)
  end
end

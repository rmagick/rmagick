#!/usr/bin/env ruby -w

require 'rmagick'
require 'test/unit'
require 'test/unit/ui/console/testrunner' unless RUBY_VERSION[/^1\.9|^2/]

class EnumUT < Test::Unit::TestCase
  def test_new
    assert_nothing_raised { Magick::Enum.new(:foo, 42) }
    assert_nothing_raised { Magick::Enum.new('foo', 42) }

    assert_raise(TypeError) { Magick::Enum.new(Object.new, 42) }
    assert_raise(TypeError) { Magick::Enum.new(:foo, 'x') }
  end

  def test_to_s
    enum = Magick::Enum.new(:foo, 42)
    assert_equal('foo', enum.to_s)

    enum = Magick::Enum.new('foo', 42)
    assert_equal('foo', enum.to_s)
  end

  def test_to_i
    enum = Magick::Enum.new(:foo, 42)
    assert_equal(42, enum.to_i)
  end

  def test_spaceship
    enum1 = Magick::Enum.new(:foo, 42)
    enum2 = Magick::Enum.new(:foo, 56)
    enum3 = Magick::Enum.new(:foo, 36)
    enum4 = Magick::Enum.new(:foo, 42)

    assert_equal(-1, enum1 <=> enum2)
    assert_equal(0, enum1 <=> enum4)
    assert_equal(1, enum1 <=> enum3)
    assert_nil(enum1 <=> 'x')
  end

  def test_case_eq
    enum1 = Magick::Enum.new(:foo, 42)
    enum2 = Magick::Enum.new(:foo, 56)

    assert_true(enum1 === enum1)
    assert_false(enum1 === enum2)
    assert_false(enum1 === 'x')
  end

  def test_bitwise_or
    enum1 = Magick::Enum.new(:foo, 42)
    enum2 = Magick::Enum.new(:bar, 56)

    enum = enum1 | enum2
    assert_equal(58, enum.to_i)
    assert_equal('foo|bar', enum.to_s)

    assert_raise(ArgumentError) { enum1 | 'x' }
  end

  def test_type_values
    assert_instance_of(Array, Magick::AlignType.values)

    assert_equal('UndefinedAlign', Magick::AlignType.values[0].to_s)
    assert_equal(0, Magick::AlignType.values[0].to_i)

    Magick::AlignType.values do |enum|
      assert_kind_of(Magick::Enum, enum)
      assert_instance_of(Magick::AlignType, enum)
    end
  end

  def test_type_inspect
    assert_equal('UndefinedAlign=0', Magick::AlignType.values[0].inspect)
  end

  def test_using_compose_does_not_cause_endless_loop
    img = Magick::Image.new(10, 10)
    Magick::CompositeOperator.values do |op|
      img.compose = op
      assert_equal(op, img.compose)
    end
  end

  def test_using_class_type_does_not_cause_endless_loop
    img = Magick::Image.new(1, 1)
    Magick::ClassType.values do |value|
      next if value == Magick::UndefinedClass

      img.class_type = value
      assert_equal(value, img.class_type)
    end
  end

  def test_using_filter_does_not_cause_endless_loop
    img = Magick::Image.new(1, 1)
    Magick::FilterType.values do |value|
      img.filter = value
      assert_equal(value, img.filter)
    end
  end

  def test_using_pixel_interpolation_method_does_not_cause_endless_loop
    img = Magick::Image.new(1, 1)
    Magick::PixelInterpolateMethod.values do |value|
      img.pixel_interpolation_method = value
      assert_equal(value, img.pixel_interpolation_method)
    end
  end

  def test_using_virtual_pixel_method_does_not_cause_endless_loop
    img = Magick::Image.new(1, 1)
    Magick::VirtualPixelMethod.values do |value|
      img.virtual_pixel_method = value
      assert_equal(value, img.virtual_pixel_method)
    end
  end
end

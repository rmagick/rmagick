#!/usr/bin/env ruby -w

require 'rmagick'
require 'test/unit'
require 'test/unit/ui/console/testrunner'

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

  def test_using_colorspace_type_does_not_cause_endless_loop
    img = Magick::Image.new(1, 1)
    Magick::ColorspaceType.values do |value|
      next if value == Magick::SRGBColorspace

      assert_not_equal(value, img.colorspace)
    end
  end

  def test_using_compression_type_does_not_cause_endless_loop
    img = Magick::Image.new(1, 1)
    Magick::CompressionType.values do |value|
      img.compression = value
      assert_equal(value, img.compression)
    end
  end

  def test_using_dispose_type_does_not_cause_endless_loop
    img = Magick::Image.new(1, 1)
    Magick::DisposeType.values do |value|
      img.dispose = value
      assert_equal(value, img.dispose)
    end
  end

  def test_using_endian_type_does_not_cause_endless_loop
    img = Magick::Image.new(1, 1)
    Magick::EndianType.values do |value|
      img.endian = value
      assert_equal(value, img.endian)
    end
  end

  def test_using_filter_does_not_cause_endless_loop
    img = Magick::Image.new(1, 1)
    Magick::FilterType.values do |value|
      img.filter = value
      assert_equal(value, img.filter)
    end
  end

  def test_using_gravity_type_does_not_cause_endless_loop
    img = Magick::Image.new(1, 1)
    Magick::GravityType.values do |value|
      img.gravity = value
      assert_equal(value, img.gravity)
    end
  end

  def test_using_image_type_does_not_cause_endless_loop
    info = Magick::Image::Info.new
    Magick::ImageType.values do |value|
      info.image_type = value
      assert_equal(value, info.image_type)
    end
  end

  def test_using_orientation_type_does_not_cause_endless_loop
    info = Magick::Image::Info.new
    Magick::OrientationType.values do |value|
      info.orientation = value
      assert_equal(value, info.orientation)
    end
  end

  def test_using_interlace_type_does_not_cause_endless_loop
    info = Magick::Image::Info.new
    Magick::InterlaceType.values do |value|
      info.interlace = value
      assert_equal(value, info.interlace)
    end
  end

  def test_using_pixel_interpolation_method_does_not_cause_endless_loop
    img = Magick::Image.new(1, 1)
    Magick::PixelInterpolateMethod.values do |value|
      img.pixel_interpolation_method = value
      assert_equal(value, img.pixel_interpolation_method)
    end
  end

  def test_using_rendering_intent_does_not_cause_endless_loop
    img = Magick::Image.new(1, 1)
    Magick::RenderingIntent.values do |value|
      img.rendering_intent = value
      assert_equal(value, img.rendering_intent)
    end
  end

  def test_using_resolution_type_does_not_cause_endless_loop
    info = Magick::Image::Info.new
    Magick::ResolutionType.values do |value|
      info.units = value
      assert_equal(value, info.units)
    end
  end

  def test_using_virtual_pixel_method_does_not_cause_endless_loop
    img = Magick::Image.new(1, 1)
    Magick::VirtualPixelMethod.values do |value|
      img.virtual_pixel_method = value
      assert_equal(value, img.virtual_pixel_method)
    end
  end

  def test_storage_type_name
    img = Magick::Image.new(20, 20)
    pixels = img.export_pixels(0, 0, 20, 20, 'RGB').pack('D*')

    assert_raise_message(/UndefinedPixel/) do
      img.import_pixels(0, 0, 20, 20, 'RGB', pixels, Magick::UndefinedPixel)
    end
  end

  def test_stretch_type_name
    Magick::StretchType.values do |stretch|
      font = Magick::Font.new('Arial', 'font test', 'Arial family', Magick::NormalStyle, stretch, 400, nil, 'test foundry', 'test format')
      assert_match(/stretch=#{stretch.to_s}/, font.to_s)
    end

    font = Magick::Font.new('Arial', 'font test', 'Arial family', Magick::NormalStyle, nil, 400, nil, 'test foundry', 'test format')
    assert_match(/stretch=UndefinedStretch/, font.to_s)
  end

  def test_style_type_name
    Magick::StyleType.values do |style|
      font = Magick::Font.new('Arial', 'font test', 'Arial family', style, Magick::NormalStretch, 400, nil, 'test foundry', 'test format')
      assert_match(/style=#{style.to_s}/, font.to_s)
    end

    font = Magick::Font.new('Arial', 'font test', 'Arial family', nil, Magick::NormalStretch, 400, nil, 'test foundry', 'test format')
    assert_match(/style=UndefinedStyle/, font.to_s)
  end
end

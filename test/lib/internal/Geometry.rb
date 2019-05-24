#!/usr/bin/env ruby -w

require 'rmagick'
require 'test/unit'
require 'test/unit/ui/console/testrunner'

class LibGeometryUT < Test::Unit::TestCase
  def test_constants
    assert_kind_of(Magick::GeometryValue, Magick::PercentGeometry)
    assert_equal('PercentGeometry', Magick::PercentGeometry.to_s)
    assert_equal(1, Magick::PercentGeometry.to_i)

    assert_kind_of(Magick::GeometryValue, Magick::AspectGeometry)
    assert_equal('AspectGeometry', Magick::AspectGeometry.to_s)
    assert_equal(2, Magick::AspectGeometry.to_i)

    assert_kind_of(Magick::GeometryValue, Magick::LessGeometry)
    assert_equal('LessGeometry', Magick::LessGeometry.to_s)
    assert_equal(3, Magick::LessGeometry.to_i)

    assert_kind_of(Magick::GeometryValue, Magick::GreaterGeometry)
    assert_equal('GreaterGeometry', Magick::GreaterGeometry.to_s)
    assert_equal(4, Magick::GreaterGeometry.to_i)

    assert_kind_of(Magick::GeometryValue, Magick::AreaGeometry)
    assert_equal('AreaGeometry', Magick::AreaGeometry.to_s)
    assert_equal(5, Magick::AreaGeometry.to_i)

    assert_kind_of(Magick::GeometryValue, Magick::MinimumGeometry)
    assert_equal('MinimumGeometry', Magick::MinimumGeometry.to_s)
    assert_equal(6, Magick::MinimumGeometry.to_i)
  end

  def test_initialize
    assert_raise(ArgumentError) { Magick::Geometry.new(Magick::PercentGeometry) }
    assert_raise(ArgumentError) { Magick::Geometry.new(0, Magick::PercentGeometry) }
    assert_raise(ArgumentError) { Magick::Geometry.new(0, 0, Magick::PercentGeometry) }
    assert_raise(ArgumentError) { Magick::Geometry.new(0, 0, 0, Magick::PercentGeometry) }

    assert_raise(ArgumentError) { Magick::Geometry.new(-1) }
    assert_raise(ArgumentError) { Magick::Geometry.new(0, -1) }

    geometry = Magick::Geometry.new
    assert_equal(0, geometry.width)
    assert_equal(0, geometry.height)
    assert_equal(0, geometry.x)
    assert_equal(0, geometry.y)
    assert_nil(geometry.flag)

    geometry = Magick::Geometry.new(10, 20, 30, 40)
    assert_equal(10, geometry.width)
    assert_equal(20, geometry.height)
    assert_equal(30, geometry.x)
    assert_equal(40, geometry.y)
  end

  def test_to_s
    assert_equal('', Magick::Geometry.new.to_s)
    assert_equal('10x', Magick::Geometry.new(10).to_s)
    assert_equal('10x20', Magick::Geometry.new(10, 20).to_s)
    assert_equal('10x20+30+0', Magick::Geometry.new(10, 20, 30).to_s)
    assert_equal('10x20+30+40', Magick::Geometry.new(10, 20, 30, 40).to_s)
    assert_equal('x20+30+40', Magick::Geometry.new(0, 20, 30, 40).to_s)
    assert_equal('+30+40', Magick::Geometry.new(0, 0, 30, 40).to_s)
    assert_equal('+0+40', Magick::Geometry.new(0, 0, 0, 40).to_s)

    assert_equal('10%x20%+30+40', Magick::Geometry.new(10, 20, 30, 40, Magick::PercentGeometry).to_s)
    assert_equal('x20%+30+40', Magick::Geometry.new(0, 20, 30, 40, Magick::PercentGeometry).to_s)

    assert_equal('10.20x20.50+30+40', Magick::Geometry.new(10.2, 20.5, 30, 40).to_s)
    assert_equal('10.20%x20.50%+30+40', Magick::Geometry.new(10.2, 20.5, 30, 40, Magick::PercentGeometry).to_s)
  end

  def test_from_s
    assert_equal('', Magick::Geometry.from_s('').to_s)
    assert_equal('', Magick::Geometry.from_s('x').to_s)
    assert_equal('10x', Magick::Geometry.from_s('10').to_s)
    assert_equal('10x', Magick::Geometry.from_s('10x').to_s)
    assert_equal('10x20', Magick::Geometry.from_s('10x20').to_s)
    assert_equal('10x20+30+40', Magick::Geometry.from_s('10x20+30+40').to_s)
    assert_equal('x20+30+40', Magick::Geometry.from_s('x20+30+40').to_s)
    assert_equal('+30+40', Magick::Geometry.from_s('+30+40').to_s)
    assert_equal('+0+40', Magick::Geometry.from_s('+0+40').to_s)
    assert_equal('+30+0', Magick::Geometry.from_s('+30').to_s)

    assert_equal('10%x20%+30+40', Magick::Geometry.from_s('10%x20%+30+40').to_s)
    assert_equal('x20%+30+40', Magick::Geometry.from_s('x20%+30+40').to_s)

    assert_equal('10.20x20.50+30+40', Magick::Geometry.from_s('10.2x20.5+30+40').to_s)
    assert_equal('10.20%x20.50%+30+40', Magick::Geometry.from_s('10.2%x20.500%+30+40').to_s)

    assert_raise(ArgumentError) { Magick::Geometry.from_s('10x20+') }
    assert_raise(ArgumentError) { Magick::Geometry.from_s('+30.000+40') }
    assert_raise(ArgumentError) { Magick::Geometry.from_s('+30.000+40.000') }
    assert_raise(ArgumentError) { Magick::Geometry.from_s('10x20+30.000+40') }
    assert_raise(ArgumentError) { Magick::Geometry.from_s('10x20+30.000+40.000') }
  end
end

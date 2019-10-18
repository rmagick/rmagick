require 'rmagick'
require 'minitest/autorun'

class LibGeometryUT < Minitest::Test
  def test_constants
    assert_kind_of(Magick::GeometryValue, Magick::PercentGeometry)
    expect(Magick::PercentGeometry.to_s).to eq('PercentGeometry')
    expect(Magick::PercentGeometry.to_i).to eq(1)

    assert_kind_of(Magick::GeometryValue, Magick::AspectGeometry)
    expect(Magick::AspectGeometry.to_s).to eq('AspectGeometry')
    expect(Magick::AspectGeometry.to_i).to eq(2)

    assert_kind_of(Magick::GeometryValue, Magick::LessGeometry)
    expect(Magick::LessGeometry.to_s).to eq('LessGeometry')
    expect(Magick::LessGeometry.to_i).to eq(3)

    assert_kind_of(Magick::GeometryValue, Magick::GreaterGeometry)
    expect(Magick::GreaterGeometry.to_s).to eq('GreaterGeometry')
    expect(Magick::GreaterGeometry.to_i).to eq(4)

    assert_kind_of(Magick::GeometryValue, Magick::AreaGeometry)
    expect(Magick::AreaGeometry.to_s).to eq('AreaGeometry')
    expect(Magick::AreaGeometry.to_i).to eq(5)

    assert_kind_of(Magick::GeometryValue, Magick::MinimumGeometry)
    expect(Magick::MinimumGeometry.to_s).to eq('MinimumGeometry')
    expect(Magick::MinimumGeometry.to_i).to eq(6)
  end

  def test_initialize
    assert_raise(ArgumentError) { Magick::Geometry.new(Magick::PercentGeometry) }
    assert_raise(ArgumentError) { Magick::Geometry.new(0, Magick::PercentGeometry) }
    assert_raise(ArgumentError) { Magick::Geometry.new(0, 0, Magick::PercentGeometry) }
    assert_raise(ArgumentError) { Magick::Geometry.new(0, 0, 0, Magick::PercentGeometry) }

    assert_raise(ArgumentError) { Magick::Geometry.new(-1) }
    assert_raise(ArgumentError) { Magick::Geometry.new(0, -1) }

    geometry = Magick::Geometry.new
    expect(geometry.width).to eq(0)
    expect(geometry.height).to eq(0)
    expect(geometry.x).to eq(0)
    expect(geometry.y).to eq(0)
    assert_nil(geometry.flag)

    geometry = Magick::Geometry.new(10, 20, 30, 40)
    expect(geometry.width).to eq(10)
    expect(geometry.height).to eq(20)
    expect(geometry.x).to eq(30)
    expect(geometry.y).to eq(40)
  end

  def test_to_s
    expect(Magick::Geometry.new.to_s).to eq('')
    expect(Magick::Geometry.new(10).to_s).to eq('10x')
    expect(Magick::Geometry.new(10, 20).to_s).to eq('10x20')
    expect(Magick::Geometry.new(10, 20, 30).to_s).to eq('10x20+30+0')
    expect(Magick::Geometry.new(10, 20, 30, 40).to_s).to eq('10x20+30+40')
    expect(Magick::Geometry.new(0, 20, 30, 40).to_s).to eq('x20+30+40')
    expect(Magick::Geometry.new(0, 0, 30, 40).to_s).to eq('+30+40')
    expect(Magick::Geometry.new(0, 0, 0, 40).to_s).to eq('+0+40')

    expect(Magick::Geometry.new(10, 20, 30, 40, Magick::PercentGeometry).to_s).to eq('10%x20%+30+40')
    expect(Magick::Geometry.new(0, 20, 30, 40, Magick::PercentGeometry).to_s).to eq('x20%+30+40')

    expect(Magick::Geometry.new(10.2, 20.5, 30, 40).to_s).to eq('10.20x20.50+30+40')
    expect(Magick::Geometry.new(10.2, 20.5, 30, 40, Magick::PercentGeometry).to_s).to eq('10.20%x20.50%+30+40')
  end

  def test_from_s
    expect(Magick::Geometry.from_s('').to_s).to eq('')
    expect(Magick::Geometry.from_s('x').to_s).to eq('')
    expect(Magick::Geometry.from_s('10').to_s).to eq('10x')
    expect(Magick::Geometry.from_s('10x').to_s).to eq('10x')
    expect(Magick::Geometry.from_s('10x20').to_s).to eq('10x20')
    expect(Magick::Geometry.from_s('10x20+30+40').to_s).to eq('10x20+30+40')
    expect(Magick::Geometry.from_s('x20+30+40').to_s).to eq('x20+30+40')
    expect(Magick::Geometry.from_s('+30+40').to_s).to eq('+30+40')
    expect(Magick::Geometry.from_s('+0+40').to_s).to eq('+0+40')
    expect(Magick::Geometry.from_s('+30').to_s).to eq('+30+0')

    expect(Magick::Geometry.from_s('10%x20%+30+40').to_s).to eq('10%x20%+30+40')
    expect(Magick::Geometry.from_s('x20%+30+40').to_s).to eq('x20%+30+40')

    expect(Magick::Geometry.from_s('10.2x20.5+30+40').to_s).to eq('10.20x20.50+30+40')
    expect(Magick::Geometry.from_s('10.2%x20.500%+30+40').to_s).to eq('10.20%x20.50%+30+40')

    assert_raise(ArgumentError) { Magick::Geometry.from_s('10x20+') }
    assert_raise(ArgumentError) { Magick::Geometry.from_s('+30.000+40') }
    assert_raise(ArgumentError) { Magick::Geometry.from_s('+30.000+40.000') }
    assert_raise(ArgumentError) { Magick::Geometry.from_s('10x20+30.000+40') }
    assert_raise(ArgumentError) { Magick::Geometry.from_s('10x20+30.000+40.000') }
  end
end

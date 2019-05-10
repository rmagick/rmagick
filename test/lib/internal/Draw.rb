require 'rmagick'
require 'test/unit'
require 'test/unit/ui/console/testrunner' unless RUBY_VERSION[/^1\.9|^2/]

class LibDrawUT < Test::Unit::TestCase
  def setup
    @draw = Magick::Draw.new
  end

  def test_bezier
    @draw.bezier(10, '20', '20.5', 30, 40.5, 50)
    assert_equal('bezier 10,20,20.5,30,40.5,50', @draw.inspect)

    assert_raise(ArgumentError) { @draw.bezier }
    assert_raise(ArgumentError) { @draw.bezier(1) }
    assert_raise(ArgumentError) { @draw.bezier('x', 20, 30, 40.5) }
  end
end

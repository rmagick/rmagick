require 'rmagick'
require 'test/unit'
require 'test/unit/ui/console/testrunner' unless RUBY_VERSION[/^1\.9|^2/]

class PolaroidOptionsUT < Test::Unit::TestCase
  def setup
    @options = Magick::Image::PolaroidOptions.new
  end

  def test_shadow_color
    assert_nothing_raised { @options.shadow_color = "gray50" }

    @options.freeze
    assert_raise(FreezeError) { @options.shadow_color = "gray50" }
  end

  def test_border_color
    assert_nothing_raised { @options.border_color = "gray50" }

    @options.freeze
    assert_raise(FreezeError) { @options.border_color = "gray50" }
  end
end

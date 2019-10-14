require 'rmagick'
require 'minitest/autorun'

class PolaroidOptionsUT < Minitest::Test
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

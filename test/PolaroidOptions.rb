require 'rmagick'
require 'minitest/autorun'

class PolaroidOptionsUT < Minitest::Test
  def setup
    @options = Magick::Image::PolaroidOptions.new
  end

  def test_shadow_color
    expect { @options.shadow_color = "gray50" }.not_to raise_error

    @options.freeze
    expect { @options.shadow_color = "gray50" }.to raise_error(FreezeError)
  end

  def test_border_color
    expect { @options.border_color = "gray50" }.not_to raise_error

    @options.freeze
    expect { @options.border_color = "gray50" }.to raise_error(FreezeError)
  end
end

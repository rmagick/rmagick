#!/usr/bin/env ruby -w

require 'rmagick'
require 'test/unit'
require 'test/unit/ui/console/testrunner' unless RUBY_VERSION[/^1\.9|^2/]

class ObsoleteUT < Test::Unit::TestCase
  def test_constants
    assert_nothing_raised { Magick::AlphaChannelType }
    assert_nothing_raised { Magick::DistortImageMethod }
    assert_nothing_raised { Magick::FilterTypes }
    assert_nothing_raised { Magick::ImageLayerMethod }
    assert_nothing_raised { Magick::InterpolatePixelMethod }
  end
end

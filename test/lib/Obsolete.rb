#!/usr/bin/env ruby -w

require 'rmagick'
require 'test/unit'
require 'test/unit/ui/console/testrunner'

class ObsoleteUT < Test::Unit::TestCase
  def test_constants
    assert_nothing_raised { Magick::AddCompositeOp }
    assert_nothing_raised { Magick::AlphaChannelType }
    assert_nothing_raised { Magick::ColorSeparationMatteType }
    assert_nothing_raised { Magick::CopyOpacityCompositeOp }
    assert_nothing_raised { Magick::DistortImageMethod }
    assert_nothing_raised { Magick::DivideCompositeOp }
    assert_nothing_raised { Magick::FilterTypes }
    assert_nothing_raised { Magick::GrayscaleMatteType }
    assert_nothing_raised { Magick::ImageLayerMethod }
    assert_nothing_raised { Magick::InterpolatePixelMethod }
    assert_nothing_raised { Magick::MeanErrorPerPixelMetric }
    assert_nothing_raised { Magick::MinusCompositeOp }
    assert_nothing_raised { Magick::PaletteBilevelMatteType }
    assert_nothing_raised { Magick::PaletteMatteType }
    assert_nothing_raised { Magick::PeakSignalToNoiseRatioMetric }
    assert_nothing_raised { Magick::SubtractCompositeOp }
    assert_nothing_raised { Magick::TrueColorMatteType }
    assert_nothing_raised { Magick::UndefinedMetric }
    assert_nothing_raised { Magick::Rec601LumaColorspace }
    assert_nothing_raised { Magick::Rec709LumaColorspace }
  end
end

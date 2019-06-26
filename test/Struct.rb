#!/usr/bin/env ruby -w

require 'rmagick'
require 'test/unit'
require 'test/unit/ui/console/testrunner'

class StructUT < Test::Unit::TestCase
  def test_chromaticity_to_s
    image = Magick::Image.new(10, 10)
    assert_match(/red_primary=\(x=.+,y=.+\) green_primary=\(x=.+,y=.+\) blue_primary=\(x=.+,y=.+\) white_point=\(x=.+,y=.+\)/, image.chromaticity.to_s)
  end

  def test_export_color_info
    color = Magick.colors[0]
    assert_instance_of(Magick::Color, color)
    assert_match(/name=.+, compliance=.+, color.red=.+, color.green=.+, color.blue=.+, color.alpha=.+/, color.to_s)
  end

  def test_export_type_info
    font = Magick.fonts[0]
    assert_match(/^name=.+, description=.+, family=.+, style=.+, stretch=.+, weight=.+, encoding=.*, foundry=.*, format=.*$/, font.to_s)
  end

  def test_export_point_info
    draw = Magick::Draw.new
    metric = draw.get_type_metrics('ABCDEF')
    assert_match(/^pixels_per_em=\(x=.+,y=.+\) ascent=.+ descent=.+ width=.+ height=.+ max_advance=.+ bounds.x1=.+ bounds.y1=.+ bounds.x2=.+ bounds.y2=.+ underline_position=.+ underline_thickness=.+$/, metric.to_s)
  end

  def test_primary_info_to_s
    chrom = Magick::Image.new(10, 10).chromaticity
    red_primary = chrom.red_primary
    assert_match(/^x=.+, y=.+, z=.+$/, red_primary.to_s)
  end

  def test_rectangle_info_to_s
    rect = Magick::Rectangle.new(10, 20, 30, 40)
    assert_equal('width=10, height=20, x=30, y=40', rect.to_s)
  end

  def test_segment_info_to_s
    segment = Magick::Segment.new(10, 20, 30, 40)
    assert_equal('x1=10, y1=20, x2=30, y2=40', segment.to_s)
  end
end

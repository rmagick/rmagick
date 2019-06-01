#!/usr/bin/env ruby -w

require 'rmagick'
require 'test/unit'
require 'test/unit/ui/console/testrunner'
require_relative 'appearance_assertion'

class AppearanceMontageUT < Test::Unit::TestCase
  include AppearanceAssertion

  def test_color
    imagelist = Magick::ImageList.new(IMAGES_DIR + '/Flower_Hat.jpg')

    new_imagelist = imagelist.montage do
      self.border_width = 100
      self.border_color = 'red'
      self.background_color = 'blue'
      self.matte_color = 'yellow'
      self.frame = '10x10'
      self.gravity = Magick::CenterGravity
    end

    # montage ../../doc/ex/images/Flower_Hat.jpg -border 100x -bordercolor red -mattecolor yellow -background blue -frame 10x10 -gravity Center expected/montage_border_color.jpg
    assert_same_image('expected/montage_border_color.jpg', new_imagelist.first)
  end
end

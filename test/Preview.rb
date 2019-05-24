#!/usr/bin/env ruby -w

require 'rmagick'
require 'test/unit'
require 'test/unit/ui/console/testrunner'

class PreviewUT < Test::Unit::TestCase
  def test_preview
    hat = Magick::Image.read(IMAGES_DIR + '/Flower_Hat.jpg').first
    assert_nothing_raised do
      prev = hat.preview(Magick::RotatePreview)
      assert_instance_of(Magick::Image, prev)
    end
    puts "\n"
    Magick::PreviewType.values do |type|
      puts "testing #{type}..."
      assert_nothing_raised { hat.preview(type) }
    end
    assert_raise(TypeError) { hat.preview(2) }
  end
end

if $PROGRAM_NAME == __FILE__
  IMAGES_DIR = '../doc/ex/images'
  Test::Unit::UI::Console::TestRunner.run(PreviewUT)
end

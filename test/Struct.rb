#!/usr/bin/env ruby -w

require 'rmagick'
require 'test/unit'
require 'test/unit/ui/console/testrunner' unless RUBY_VERSION[/^1\.9|^2/]

class StructUT < Test::Unit::TestCase
  def test_export_type_info
    font = Magick.fonts[0]
    assert_match(/^name=.+, description=.+, family=.+, style=.+, stretch=.+, weight=.+, encoding=.*, foundry=.*, format=.*$/, font.to_s)
  end
end

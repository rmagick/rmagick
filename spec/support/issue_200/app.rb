#!/usr/bin/env ruby
require 'rmagick'

begin
  Magick::Image.read(nil)
rescue StandardError
  nil
end

#! /usr/local/bin/ruby -w
require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end

require_relative '../lib/rmagick'
require 'test/unit'
require 'test/unit/ui/console/testrunner'  if !RUBY_VERSION[/^1\.9|^2/]

puts RUBY_VERSION
puts RUBY_VERSION.class

root_dir = File.expand_path("../..", __FILE__)
$LOAD_PATH.push(root_dir)

IMAGES_DIR = File.join(root_dir, 'doc/ex/images')
FILES = Dir[IMAGES_DIR+'/Button_*.gif'].sort
FLOWER_HAT = IMAGES_DIR+'/Flower_Hat.jpg'
IMAGE_WITH_PROFILE = IMAGES_DIR+'/image_with_profile.jpg'

Magick::Magick_version =~ /ImageMagick (\d+\.\d+\.\d+)-(\d+) /
abort "Unable to get ImageMagick version" unless $1 && $2

IM_VERSION = Gem::Version.new($1)
IM_REVISION = Gem::Version.new($2)

require_relative 'Image1.rb'
require_relative 'Image2.rb'
require_relative 'Image3.rb'
require_relative 'ImageList1.rb'
require_relative 'ImageList2.rb'
require_relative 'Image_attributes.rb'
require_relative 'Import_Export.rb'
require_relative 'Pixel.rb'
require_relative 'Preview.rb'
require_relative 'Info.rb'
require_relative 'Magick.rb'
require_relative 'Draw.rb'

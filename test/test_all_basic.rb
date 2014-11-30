#! /usr/local/bin/ruby -w
require 'RMagick'
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

require 'Image1.rb'
require 'Image2.rb'
require 'Image3.rb'
require 'ImageList1.rb'
require 'ImageList2.rb'
require 'Image_attributes.rb'
require 'Import_Export.rb'
require 'Pixel.rb'
require 'Preview.rb'
require 'Info.rb'
require 'Magick.rb'
require 'Draw.rb'


require_relative('helper')

puts RUBY_VERSION
puts RUBY_VERSION.class

root_dir = File.expand_path("../..", __FILE__)
$LOAD_PATH.push(root_dir)

IMAGES_DIR = File.join(root_dir, 'doc/ex/images')
FILES = Dir[IMAGES_DIR+'/Button_*.gif'].sort
FLOWER_HAT = IMAGES_DIR+'/Flower_Hat.jpg'
IMAGE_WITH_PROFILE = IMAGES_DIR+'/image_with_profile.jpg'

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

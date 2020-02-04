require_relative 'support/simplecov' if ENV['COVERAGE'] == 'true'
require_relative 'support/matchers'

require 'pry'
require_relative '../lib/rmagick'
require_relative '../lib/rvg/rvg'

root_dir = File.expand_path('..', __dir__)
IMAGES_DIR = File.join(root_dir, 'doc/ex/images')
SUPPORT_DIR = File.join(__dir__, 'support')
FIXTURE_PATH = File.join(__dir__, 'fixtures')
FILES = Dir[IMAGES_DIR + '/Button_*.gif'].sort
FLOWER_HAT = IMAGES_DIR + '/Flower_Hat.jpg'
IMAGE_WITH_PROFILE = IMAGES_DIR + '/image_with_profile.jpg'

Magick::Magick_version =~ /ImageMagick (\d+\.\d+\.\d+)-(\d+) /
abort 'Unable to get ImageMagick version' unless Regexp.last_match(1) && Regexp.last_match(2)
IM_VERSION = Gem::Version.new(Regexp.last_match(1))

FreezeError = RUBY_VERSION > '2.5' ? FrozenError : RuntimeError

def unsupported_before(version, condition = {})
  cond = condition.key?(:if) ? condition[:if] : true
  :skip if cond && Gem::Version.new(Magick::IMAGEMAGICK_VERSION) < Gem::Version.new(version)
end

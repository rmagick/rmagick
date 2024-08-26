# frozen_string_literal: true

require_relative 'support/simplecov' if ENV['COVERAGE'] == 'true'
require_relative 'support/matchers'
require_relative 'support/helpers'

$stderr = Module.new do
  def self.write(message)
    raise message
  end
end

require 'pry'
require 'rmagick'
require 'rvg/rvg'

root_dir = File.expand_path('..', __dir__)
IMAGES_DIR = File.join(root_dir, 'doc/ex/images')
SUPPORT_DIR = File.join(__dir__, 'support')
FIXTURE_PATH = File.join(__dir__, 'fixtures')
FILES = Dir[IMAGES_DIR + '/Button_*.gif']
FLOWER_HAT = IMAGES_DIR + '/Flower_Hat.jpg'
IMAGE_WITH_PROFILE = IMAGES_DIR + '/image_with_profile.jpg'

Magick::Magick_version =~ /ImageMagick (\d+\.\d+\.\d+)-(\d+) /
abort 'Unable to get ImageMagick version' unless Regexp.last_match(1) && Regexp.last_match(2)
IM_VERSION = Gem::Version.new(Regexp.last_match(1))

def unsupported_before(version, condition = {})
  cond = condition.key?(:if) ? condition[:if] : true
  message = "Unsupported before #{version}; running #{Magick::IMAGEMAGICK_VERSION}"
  { skip: message } if cond && Gem::Version.new(Magick::IMAGEMAGICK_VERSION) < Gem::Version.new(version)
end

def supported_before(version, condition = {})
  cond = condition.key?(:if) ? condition[:if] : true
  message = "Supported before #{version}; running #{Magick::IMAGEMAGICK_VERSION}"
  { skip: message } if cond && Gem::Version.new(Magick::IMAGEMAGICK_VERSION) >= Gem::Version.new(version)
end

RSpec.configure do |config|
  config.include(TestHelpers)
end

if GC.respond_to?(:verify_compaction_references)
  at_exit do
    # Verify to move objects around, helping to find GC compaction bugs.
    # Run last, because it may consider more effective if the object
    # has been generated to some extent.
    if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.2.0')
      GC.verify_compaction_references(expand_heap: true, toward: :empty)
    else
      GC.verify_compaction_references(double_heap: true, toward: :empty)
    end
  end
end

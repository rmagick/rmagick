# frozen_string_literal: true

require_relative 'support/simplecov' if ENV['COVERAGE'] == 'true'
require_relative 'support/matchers'
require_relative 'support/helpers'

require 'pry'
require 'rmagick'
require 'rvg/rvg'

root_dir = File.expand_path('..', __dir__)
IMAGES_DIR = File.join(root_dir, 'doc/ex/images')
FIXTURE_PATH = File.join(__dir__, 'fixtures')
FILES = Dir[IMAGES_DIR + '/Button_*.gif']
FLOWER_HAT = IMAGES_DIR + '/Flower_Hat.jpg'
IMAGE_WITH_PROFILE = IMAGES_DIR + '/image_with_profile.jpg'

RSpec.configure do |config|
  config.include(TestHelpers)
end

if GC.respond_to?(:verify_compaction_references)
  at_exit do
    # Verify to move objects around, helping to find GC compaction bugs.
    # Run last, because it may consider more effective if the object
    # has been generated to some extent.
    GC.verify_compaction_references(expand_heap: true, toward: :empty)
  end
end

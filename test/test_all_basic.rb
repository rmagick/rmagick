root_dir = File.expand_path('..', __dir__)
IMAGES_DIR = File.join(root_dir, 'doc/ex/images')
FILES = Dir[IMAGES_DIR + '/Button_*.gif'].sort
FLOWER_HAT = IMAGES_DIR + '/Flower_Hat.jpg'
IMAGE_WITH_PROFILE = IMAGES_DIR + '/image_with_profile.jpg'

require 'simplecov'
require 'minitest/autorun'
require 'pry'
$LOAD_PATH.unshift(File.join(root_dir, 'lib'))
$LOAD_PATH.unshift(File.join(root_dir, 'test'))

require 'rmagick'

Magick::Magick_version =~ /ImageMagick (\d+\.\d+\.\d+)-(\d+) /
abort 'Unable to get ImageMagick version' unless Regexp.last_match(1) && Regexp.last_match(2)

IM_VERSION = Gem::Version.new(Regexp.last_match(1))
IM_REVISION = Gem::Version.new(Regexp.last_match(2))

FreezeError = RUBY_VERSION > '2.5' ? FrozenError : RuntimeError

Dir.glob(File.join(__dir__, 'lib/**/*.rb')) do |file|
  require file
end

Dir.glob(File.join(__dir__, 'appearance/**/*.rb')) do |file|
  require file
end

module Minitest
  module Assertions
    def assert_nothing_raised
      yield
    end

    def assert_block
      assert(yield)
    end

    def expect(actual)
      @actual = actual
      self
    end

    def to(matcher)
      case matcher
      when :eq
        assert_equal(@expected, @actual)
      else
        raise ArgumentError, "no matcher: #{matcher.inspect}"
      end
    end

    def eq(expected)
      @expected = expected
      :eq
    end

    alias assert_nothing_thrown assert_nothing_raised
    alias assert_raise assert_raises
    alias assert_not_same refute_same
    alias assert_not_equal refute_equal
    alias assert_not_nil refute_nil
    alias assert_true assert
    alias assert_false refute
  end
end

require 'Draw.rb'
require 'Enum.rb'
require 'Fill.rb'
require 'Image1.rb'
require 'Image2.rb'
require 'Image3.rb'
require 'ImageList1.rb'
require 'ImageList2.rb'
require 'Image_attributes.rb'
require 'Import_Export.rb'
require 'Info.rb'
require 'KernelInfo.rb'
require 'Magick.rb'
require 'Pixel.rb'
require 'PolaroidOptions.rb'
require 'Preview.rb'
require 'Struct.rb'

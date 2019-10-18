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
    def assert_block
      assert(yield)
    end

    def expect(actual = :__not_set__, &actual_block)
      @actual = actual
      @actual_block = actual_block
      self
    end

    def to(matcher)
      case matcher
      when :be
        assert_same(@expected, @actual)
      when :be_instance_of
        assert_instance_of(@expected, @actual)
      when :be_kind_of
        assert_kind_of(@expected, @actual)
      when :eq
        assert_equal(@expected, @actual)
      when :raise_error
        assert_raises(@expected, &@actual_block)
      else
        raise ArgumentError, "no matcher: #{matcher.inspect}"
      end
    end

    def not_to(matcher)
      case matcher
      when :be
        refute_same(@expected, @actual)
      when :raise_error
        @actual_block.call
      else
        raise ArgumentError, "no negated matcher: #{matcher.inspect}"
      end
    end

    def be(expected)
      @expected = expected
      :be
    end

    def be_instance_of(expected)
      @expected = expected
      :be_instance_of
    end

    def be_kind_of(expected)
      @expected = expected
      :be_kind_of
    end

    def eq(expected)
      @expected = expected
      :eq
    end

    def raise_error(expected = :__not_set__)
      @expected = expected
      :raise_error
    end

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

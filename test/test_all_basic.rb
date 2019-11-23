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
  class RSpecMatcher
    attr_accessor :type, :delta, :expected

    def initialize(type, expected)
      self.type = type
      type == :be_within ? self.delta = expected : self.expected = expected
    end

    def of(expected)
      self.expected = expected
      self
    end
  end

  module Expectations
    def to(matcher)
      case matcher.type
      when :be
        ctx.assert_same(matcher.expected, target)
      when :be_instance_of
        ctx.assert_instance_of(matcher.expected, target)
      when :be_kind_of
        ctx.assert_kind_of(matcher.expected, target)
      when :be_within
        ctx.assert_in_delta(matcher.expected, target, matcher.delta)
      when :eq
        ctx.assert_equal(matcher.expected, target)
      when :have_key
        ctx.assert(target.key?(matcher.expected))
      when :include
        ctx.assert(target.include?(matcher.expected))
      when :match
        ctx.assert_match(matcher.expected, target)
      when :raise_error
        ctx.assert_raises(matcher.expected, &target)
      when :respond_to
        ctx.assert(target.respond_to?(matcher.expected))
      else
        raise ArgumentError, "no matcher: #{matcher.inspect}"
      end
    end

    def not_to(matcher)
      case matcher.type
      when :be
        ctx.refute_same(matcher.expected, target)
      when :eq
        ctx.refute_equal(matcher.expected, target)
      when :have_key
        ctx.refute(target.key?(matcher.expected))
      when :raise_error
        target.call
      else
        raise ArgumentError, "no negated matcher: #{matcher.inspect}"
      end
    end

    def be(expected)
      RSpecMatcher.new(:be, expected)
    end

    def be_instance_of(expected)
      RSpecMatcher.new(:be_instance_of, expected)
    end

    def be_kind_of(expected)
      RSpecMatcher.new(:be_kind_of, expected)
    end

    def be_within(delta)
      RSpecMatcher.new(:be_within, delta)
    end

    def have_key(expected) # rubocop:disable Naming/PredicateName
      RSpecMatcher.new(:have_key, expected)
    end

    def include(expected)
      RSpecMatcher.new(:include, expected)
    end

    def match(expected)
      RSpecMatcher.new(:match, expected)
    end

    def eq(expected)
      RSpecMatcher.new(:eq, expected)
    end

    def raise_error(expected = :__not_set__)
      RSpecMatcher.new(:raise_error, expected)
    end

    def respond_to(expected)
      RSpecMatcher.new(:respond_to, expected)
    end
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

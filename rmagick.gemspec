# frozen_string_literal: true

require 'English'
require './lib/rmagick/version'

Gem::Specification.new do |s|
  s.name = 'rmagick'
  s.version = Magick::VERSION
  s.summary = 'Ruby binding to ImageMagick'
  s.description = 'RMagick is an interface between Ruby and ImageMagick.'
  s.authors = ['Tim Hunter', 'Omer Bar-or', 'Benjamin Thomas', 'Moncef Maiza']
  s.email = 'github@benjaminfleischer.com'
  s.homepage = 'https://github.com/rmagick/rmagick'
  s.license = 'MIT'

  s.metadata['bug_tracker_uri'] = 'https://github.com/rmagick/rmagick/issues'
  s.metadata['documentation_uri'] = 'https://rmagick.github.io/'
  s.metadata['changelog_uri'] = 'https://github.com/rmagick/rmagick/blob/main/CHANGELOG.md'
  s.metadata['rubygems_mfa_required'] = 'true'

  tracked_files = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  file_exclusion_regex = /\A(doc|benchmarks|examples|spec|Steepfile)/
  files = tracked_files.reject { |file| file[file_exclusion_regex] }

  s.files = files
  s.require_paths << 'ext'

  s.extensions = %w[ext/RMagick/extconf.rb]
  s.required_ruby_version = ">= #{Magick::MIN_RUBY_VERSION}"
  s.requirements << "ImageMagick #{Magick::MIN_IM_VERSION} or later"

  s.add_dependency 'observer', '~> 0.1'
  s.add_dependency 'pkg-config', '~> 1.4'
end

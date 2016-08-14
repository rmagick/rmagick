require 'date'
require 'English'
require './lib/rmagick/version'

def v(version)
  Gem::Version.new(version)
end

RUBY     = v(RUBY_VERSION.dup)
RUBYGEMS = v(Gem::VERSION.dup)

Gem::Specification.new do |s|
  s.name = 'rmagick'
  s.version = Magick::VERSION
  s.date = Date.today.to_s
  s.summary = 'Ruby binding to ImageMagick'
  s.description = 'RMagick is an interface between Ruby and ImageMagick.'
  s.authors = ['Tim Hunter', 'Omer Bar-or', 'Benjamin Thomas', 'Moncef Maiza']
  s.email = 'github@benjaminfleischer.com'
  s.homepage = 'https://github.com/rmagick/rmagick'
  s.license = 'MIT'

  tracked_files = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  file_exclusion_regex = %r{(\Alib/rvg/to_c.rb)}
  files         = tracked_files.reject{|file| file[file_exclusion_regex] }
  test_files    = files.grep(%r{^(test|spec|features)/})
  executables   = files.grep(%r{^bin/}).map{ |f| File.basename(f) }

  s.files                       = files
  s.test_files                  = test_files
  s.executables                 = executables
  s.require_paths << 'ext' << 'deprecated'

  s.rubyforge_project = 'rmagick'
  s.extensions = %w{ext/RMagick/extconf.rb}
  s.has_rdoc = false
  s.required_ruby_version = ">= #{Magick::MIN_RUBY_VERSION}"
  s.requirements << "ImageMagick #{Magick::MIN_IM_VERSION} or later"

  s.add_development_dependency 'rspec', '~> 3.2.0'

  if RUBY < v('1.9.0')
    s.add_development_dependency 'rake', '~> 10.0'
  end

  if RUBY < v('2.0.0')
    s.add_development_dependency 'json', '~> 1.0'
  end

  if RUBY >= v('1.9.2')
    s.add_development_dependency 'rubocop', '~> 0.33.0'
  end

  if RUBY >= v('2.2.0')
    s.add_development_dependency 'test-unit', '~> 2'
  end

  if RUBYGEMS < v('1.8.25')
    s.add_development_dependency 'rake-compiler', '~> 0.8.0'
  else
    s.add_development_dependency 'rake-compiler'
  end
end

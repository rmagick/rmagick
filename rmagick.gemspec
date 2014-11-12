require 'date'
require './lib/rmagick/version'
Gem::Specification.new do |s|
  s.name = %q{rmagick}
  s.version = Magick::VERSION
  s.date = Date.today.to_s
  s.summary = %q{Ruby binding to ImageMagick}
  s.description = %q{RMagick is an interface between Ruby and ImageMagick.}
  s.authors = [%q{Tim Hunter}, %q{Omer Bar-or}, %q{Benjamin Thomas}, %q{Moncef Maiza}]
  s.post_install_message = "Please report any bugs. See https://github.com/gemhome/rmagick/compare/RMagick_2-13-2...master and https://github.com/rmagick/rmagick/issues/18"
  s.email = %q{github@benjaminfleischer.com}
  s.homepage = %q{https://github.com/gemhome/rmagick}
  s.license = 'MIT'

      tracked_files = `git ls-files`.split($\)
      file_exclusion_regex = %r{(\Alib/rvg/to_c.rb)}
      files         = tracked_files.reject{|file| file[file_exclusion_regex] }
      test_files    = files.grep(%r{^(test|spec|features)/})
      executables   = files.grep(%r{^bin/}).map{ |f| File.basename(f) }

  s.files                       = files
  s.test_files                  = test_files
  s.executables                 = executables
  s.require_paths << 'ext'

  s.rubyforge_project = %q{rmagick}
  s.extensions = %w{ext/RMagick/extconf.rb}
  s.has_rdoc = false
  s.required_ruby_version = ">= #{Magick::MIN_RUBY_VERSION}"
  s.requirements << "ImageMagick #{Magick::MIN_IM_VERSION} or later"
  s.add_development_dependency 'rake-compiler'
end

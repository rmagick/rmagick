require 'date'
require './lib/rmagick/version'
Gem::Specification.new do |spec|
  spec.name          = %q{rmagick}
  spec.version       = Magick::VERSION
  spec.summary       = %q{Ruby binding for ImageMagick}
  spec.description   = %q{RMagick is an interface between Ruby and ImageMagick.}
  spec.authors = [%q{Tim Hunter}, %q{Omer Bar-or}, %q{Benjamin Thomas}, %q{Moncef Maiza}]
  spec.post_install_message = "Please report any bugspec. See https://github.com/gemhome/rmagick/compare/RMagick_2-13-2...master and https://github.com/rmagick/rmagick/issues/18"
  spec.email = %q{github@benjaminfleischer.com}
  spec.homepage = %q{https://github.com/gemhome/rmagick}
  spec.license = 'MIT'
  
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.has_rdoc = "yard"

  spec.require_paths << 'ext'
  spec.rubyforge_project = %q{rmagick}
  spec.extensions = %w{ext/RMagick/extconf.rb}
  
  spec.required_ruby_version = '>= 1.9.3'
  
  spec.requirements << 'ImageMagick 6.4.9 or later'
  
  spec.add_development_dependency 'rake-compiler'
  spec.add_development_dependency 'minitest', '~> 5.4.0'
end

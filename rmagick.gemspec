require 'date'
Gem::Specification.new do |s|
  s.name = %q{rmagick}
  s.version = "2.13.3.rc1"
  s.date = Date.today.to_s
  s.summary = %q{Ruby binding to ImageMagick}
  s.description = %q{RMagick is an interface between Ruby and ImageMagick.}
  s.authors = [%q{Tim Hunter}, %q{Omer Bar-or}, %q{Benjamin Thomas}, %q{Moncef Maiza}]
  s.post_install_message = "Please report any bugs. This bugfix release may contain bugs. See https://github.com/gemhome/rmagick/compare/RMagick_2-13-2...master and https://github.com/rmagick/rmagick/issues/18"
  s.email = %q{rmagick@rubyforge.org}
  s.homepage = %q{https://github.com/gemhome/rmagick}
  s.license = 'MIT'
  s.files = Dir.glob('**/*')
  s.bindir = 'bin'
  s.executables = Dir.glob('bin/*').collect {|f| File.basename(f)}
  s.require_paths << 'ext'
  s.rubyforge_project = %q{rmagick}
  s.extensions = %w{ext/RMagick/extconf.rb}
  s.has_rdoc = false
  s.required_ruby_version = '>= 1.8.5'
  s.requirements << 'ImageMagick 6.4.9 or later'
end

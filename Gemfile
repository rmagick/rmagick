source 'https://rubygems.org'

# Specify your gem's dependencies in rmagick.gemspec
gemspec

gem 'pry', '~> 0.14'
gem 'rake-compiler', '~> 1.0'
gem 'rspec', '~> 3.8'
gem 'rspec_junit_formatter', '~> 0.6.0'
gem 'simplecov', '~> 0.16.1'
gem 'yard', '~> 0.9.24'

if RUBY_PLATFORM !~ /mswin|mingw/
  gem 'rubocop', '~> 0.81.0'
  gem 'rubocop-rspec', '~> 1.38.1'
  gem 'rubocop-performance', '~> 1.5.2'
end

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.0.0')
  # For CI
  gem 'rbs', '~> 3.4'

  gem 'steep', '~> 1.6'
end

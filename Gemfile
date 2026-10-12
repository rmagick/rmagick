# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in rmagick.gemspec
gemspec

gem 'pry', '~> 0.16'
gem 'rake-compiler', '~> 1.2'
gem 'rspec', '~> 3.13'
gem 'rspec_junit_formatter', '~> 0.6'
gem 'yard', '~> 0.9'

gem 'rubocop', '~> 1.92'
gem 'rubocop-performance', '~> 1.27'
gem 'rubocop-rspec', '~> 3.10'

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.3')
  gem 'simplecov', '~> 1.3'

  gem 'rbs', '~> 4.2'
  gem 'rubocop-on-rbs', '~> 2.2'
  gem 'steep', '~> 2.1'
end

gem 'ruby_memcheck', '~> 3.0' if RUBY_PLATFORM.include?('linux')

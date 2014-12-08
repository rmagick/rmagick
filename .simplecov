# https://github.com/colszowka/simplecov#using-simplecov-for-centralized-config
# see https://github.com/colszowka/simplecov/blob/master/lib/simplecov/defaults.rb
# vim: set ft=ruby
SimpleCov.profiles.define 'rmagick' do
  load_profile  'test_frameworks'

  add_group "Long files" do |src_file|
    src_file.lines.count > 100
  end
  class MaxLinesFilter < SimpleCov::Filter
    def matches?(source_file)
      source_file.lines.count < filter_argument
    end
  end
  add_group "Short files", MaxLinesFilter.new(5)

  # Exclude these paths from analysis
  add_filter 'bundle'
  add_filter 'bin'
end

## RUN SIMPLECOV
if ENV['COVERAGE'] =~ /\Atrue\z/i
  SimpleCov.start 'rmagick'
  puts '[COVERAGE] Running with SimpleCov HTML Formatter'
  SimpleCov.formatters = [SimpleCov::Formatter::HTMLFormatter]
end

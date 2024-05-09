require 'simplecov'
require './lib/rmagick/version'
require 'fileutils'
require 'English'
require 'bundler/gem_tasks'
require 'rake/extensiontask'
require 'rspec/core/rake_task'

task :config do
  def version
    Magick::VERSION
  end

  # e.g. 2.13.3 becomes RMagick_2-13-3
  def version_tag
    "RMagick_#{version.tr('.', '-')}"
  end

  # e.g. 2.13.3 becomes rmagick-2.13.3.gem
  def gem_name
    "rmagick-#{version}.gem"
  end

  def base
    File.expand_path(__dir__)
  end
end

desc 'abort when repo is not clean or has uncommited code'
task :assert_clean_repo do
  sh('git diff --exit-code')
  abort 'Git repo not clean' unless $CHILD_STATUS.success?
  sh('git diff-index --quiet --cached HEAD')
  abort 'Git repo not commited' unless $CHILD_STATUS.success?
end

desc 'build gem'
task build: [:config] do
  sh 'gem build -V rmagick.gemspec'
  if $CHILD_STATUS.success?
    FileUtils.mkdir_p(File.join(base, 'pkg'))
    FileUtils.mv(File.join(base, gem_name), 'pkg')
  else
    warn 'Could not build gem'
    exit $CHILD_STATUS.exitstatus
  end
end

task push_and_tag: [:build] do
  sh "gem push #{File.join(base, 'pkg', gem_name)}"
  if $CHILD_STATUS.success?
    sh "git tag -a -m \"Version #{version}\" #{version_tag}"
    puts "Tagged #{version_tag}."
    sh 'git push'
    sh 'git push --tags'
  else
    abort 'tagging aborted pushing gem failed'
  end
end

Rake::Task["release"].clear # Remove `release` task in bundler/gem_tasks
desc 'Release'
task release: %i[assert_clean_repo push_and_tag]

namespace :website do
  PATH_TO_LOCAL_WEBSITE_REPOSITORY = File.expand_path('../rmagick.github.io')

  def replace_reversion(lines)
    now = Time.new
    now = now.strftime('%m/%d/%y')

    lines.each do |line|
      line.gsub!("0.0.0", Magick::VERSION)
      line.gsub!(%r{YY/MM/DD}, now)
    end
    lines
  end

  def update_html(input_dir, output_dir, file_name)
    lines = File.readlines(File.join(input_dir, file_name))
    lines = replace_reversion(lines)
    File.open(File.join(output_dir, file_name), 'w') { |f| lines.each { |line| f.write line } }
  end

  ENTITY = {
    '&' => '&amp;',
    '>' => '&gt;',
    '<' => '&lt;'
  }.freeze

  def file_to_html(input_dir, input_file_name, output_dir, output_file_name)
    File.open(File.join(input_dir, input_file_name)) do |src|
      File.open(File.join(output_dir, output_file_name), 'w') do |dest|
        dest.puts <<~END_EXHTMLHEAD
          <!DOCTYPE public PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN""http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
          <html xmlns="http://www.w3.org/1999/xhtml">
          <head>
            <meta name="generator" content="ex2html.rb" />
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
            <link rel="stylesheet" type="text/css" href="css/popup.css" />
            <title>RMagick example: #{input_file_name}</title>
          </head>
          <body>
          <h1>#{input_file_name}</h1>
          <div class="bodybox">
          <div class="bodyfloat">
          <pre>
        END_EXHTMLHEAD

        src.each do |line|
          line.gsub!(/[&><]/) { |s| ENTITY[s] }
          dest.puts(line)
        end

        dest.puts <<~END_EXHTMLTAIL
          </pre>
          </div>
          </div>
          <div id="close"><a href="javascript:window.close();">Close window</a></div>
          </body>
          </html>
        END_EXHTMLTAIL
      end
    end
  end

  desc 'Update RMagick website HTML files'
  task :"update:html" do
    unless File.exist?(PATH_TO_LOCAL_WEBSITE_REPOSITORY)
      puts "Please clone the rmagick.github.io repository to #{PATH_TO_LOCAL_WEBSITE_REPOSITORY}"
      exit 1
    end

    Dir.glob('doc/*.html') do |file|
      update_html('doc', PATH_TO_LOCAL_WEBSITE_REPOSITORY, File.basename(file))
    end

    Dir.glob('doc/ex/*.rb') do |file|
      file_name = File.basename(file)
      file_to_html('doc/ex', file_name, PATH_TO_LOCAL_WEBSITE_REPOSITORY, "#{file_name}.html")
    end
  end

  desc 'Update RMagick website image files'
  task :"update:image" do
    unless File.exist?(PATH_TO_LOCAL_WEBSITE_REPOSITORY)
      puts "Please clone the rmagick.github.io repository to #{PATH_TO_LOCAL_WEBSITE_REPOSITORY}"
      exit 1
    end

    Rake::Task['install'].invoke

    FileUtils.rm_rf("#{PATH_TO_LOCAL_WEBSITE_REPOSITORY}/ex")
    FileUtils.cp_r('doc/ex', PATH_TO_LOCAL_WEBSITE_REPOSITORY)

    FileUtils.cd("#{PATH_TO_LOCAL_WEBSITE_REPOSITORY}/ex") do
      Dir.glob('*.rb').each do |file|
        sh "ruby #{file}"
      end
    end
  end
end

namespace :rbs do
  desc 'Validate RBS definitions'
  task :validate do
    all_sigs = Dir.glob('sig').map { |dir| "-I #{dir}" }.join(' ')
    sh("bundle exec rbs #{all_sigs} validate") do |ok, _|
      abort('one or more rbs validate failed') unless ok
    end
  end
end

RSpec::Core::RakeTask.new(:spec)

Rake::ExtensionTask.new('RMagick2') do |ext|
  ext.ext_dir = 'ext/RMagick'
end

task spec: :compile

if ENV['STYLE_CHECKS']
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
  task default: %i[rubocop]
else
  task default: %i[spec]
end

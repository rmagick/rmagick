require 'simplecov'
require 'rake'
require "bundler/gem_tasks"


## BUILD, TAG, RELEASE
require './lib/rmagick/version'
require 'fileutils'
task :config do
  def version
    Magick::VERSION
  end
  # e.g. 2.13.3 becomes RMagick_2-13-3
  def version_tag
    "RMagick_#{version.gsub(".","-")}"
  end
  # e.g. 2.13.3 becomes rmagick-2.13.3.gem
  def gem_name
    "rmagick-#{version}.gem"
  end
  def base
    File.expand_path('..', __FILE__)
  end
end

desc "abort when repo nto clean or has uncommited code"
task :assert_clean_repo do
  sh("git diff --exit-code")
  abort "Git repo not clean" unless $?.success?
  sh("git diff-index --quiet --cached HEAD")
  abort "Git repo not commited" unless $?.success?
end

desc "build gem"
task :build => [:config] do
  sh "gem build -V rmagick.gemspec"
  if $?.success?
    FileUtils.mkdir_p(File.join(base, 'pkg'))
    FileUtils.mv(File.join(base, gem_name), 'pkg')
  else
    STDERR.puts "Could not build gem"
    exit $?.exitstatus
  end
end

task :push_and_tag => [:build] do
  sh "gem push #{File.join(base, 'pkg', gem_name)}"
  if $?.success?
    sh "git tag -a -m \"Version #{version}\" #{version_tag}"
    STDOUT.puts "Tagged #{version_tag}."
    sh "git push"
    sh "git push --tags"
  else
    abort "tagging aborted pushing gem failed"
  end
end

desc "Release"
task :release => [:assert_clean_repo, :push_and_tag]

desc "Release and build the legacy way"
task :legacy_release=> ["legacy:README.html", "legacy:extconf", "legacy:doc", "legacy:manifest", "release"]

namespace :legacy do
  require 'find'

  task :redcloth do
    require 'redcloth'
  end

  README = "README.html"
  MANIFEST = "ext/RMagick/MANIFEST"

  # Change the version number placeholders in a file.
  # Returns an array of lines from the file.
  def reversion(name)
    now = Time.new
    now = now.strftime("%m/%d/%y")

    lines = File.readlines name
    lines.each do |line|
      line.gsub!(%r{0\.0\.0}, Magick::VERSION)
      line.gsub!(%r{YY/MM/DD}, now)
    end
    lines
  end

  # Rewrite a file containing embedded version number placeholders.
  def reversion_file(name)
    lines = reversion(name)
    tmp_name = name + "_tmp"
    mv name, tmp_name
    begin
      File.open(name, "w") { |f| lines.each { |line| f.write line } }
    rescue
      mv tmp_name, name
    ensure
      rm tmp_name
    end
  end

  desc "Update version in extconf"
  task :extconf do
    reversion_file "ext/RMagick/extconf.rb"
  end

  desc "Build README.txt from README.textile using RedCloth"
  task "README.txt" => [:redcloth] do
    reversion_file "README.textile"
    body = File.readlines "README.textile"
    body = RedCloth.new(body.join).to_html + "\n"
    File.open("README.txt", "w") { |f| f.write body }
  end

  desc "Build README.html from README.txt"
  task README => "README.txt" do
    puts "writing #{README}"
    File.open(README, "w") do |html|
      html.write <<END_HTML_HEAD
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
  <head>
    <title>RMagick #{Magick::VERSION} README</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <meta name="GENERATOR" content="RedCloth">
  </head>
  <body>
END_HTML_HEAD
      html.write File.readlines("README.txt")
      html.write <<END_HTML_TAIL
  </body>
</html>
END_HTML_TAIL
    end
  end

  desc "Update versions in html files"
  task :doc do
    Dir.chdir("doc") do
      FileList["*.html"].each { |d| reversion_file(d) }
    end
  end

  # Remove files we don't want in the tarball.
  # Ensure files are not executable. (ref: bug #10080)
  desc "Remove files we don't want in the .gem; ensure files are not executable"
  task :fix_files do
    rm "README.txt", :verbose => true
    chmod 0644, FileList["doc/*.html", "doc/ex/*.rb", "doc/ex/images/*", "examples/*.rb"]
  end

  desc "Build manifest"
  task :manifest do
    now = Time.new
    now = now.strftime("%H:%M:%S %m/%d/%y")
    puts "generating #{MANIFEST}"

    File.open(MANIFEST, "w") do |f|
      f.puts "MANIFEST for #{Magick::VERSION} - #{now}\n\n"
      Find.find('.') do |name|
        next if File.directory? name
        f.puts name[2..-1]    # remove leading "./"
      end
    end
  end

end

## COMPILATION
# Given:
# ext/RMagick/extconf.rb: create_makefile("RMagick2")
# lib/rmagick_internal.rb: require 'RMagick2.so'
# #+> extension_name = "RMagick2"
# #=> gem_name = 'rmagick'
require 'rubygems/package_task'
require 'rake/extensiontask'
require 'rake/javaextensiontask'
require "rake/clean"

CLEAN.include(
  "tmp",
  "lib/1.8",
  "lib/1.9",
  "lib/2.0",
  "lib/2.1",
  "lib/RMagick2.jar",
  "lib/RMagick2.so"
)
CLOBBER.include(
  "pkg"
)

GEMSPEC = Gem::Specification.load(File.expand_path("../rmagick.gemspec", __FILE__))

Gem::PackageTask.new(GEMSPEC) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

if RUBY_PLATFORM =~ /java/
  task :java do
    puts "skipping java task"
  end
else
  Rake::ExtensionTask.new('rmagick', GEMSPEC) do |ext|
    ext.tmp_dir = 'tmp'
    ext.ext_dir = 'ext/RMagick'
    ext.cross_compile = true
    ext.cross_platform = ['x86-mingw32', 'x64-mingw32']
  end

  ENV['RUBY_CC_VERSION'].to_s.split(':').each do |ruby_version|
    platforms = {
      "x86-mingw32" => "i686-w64-mingw32",
      "x64-mingw32" => "x86_64-w64-mingw32"
    }
    platforms.each do |platform, prefix|
      task "copy:rmagick:#{platform}:#{ruby_version}" do |t|
        %w[lib tmp/#{platform}/stage/lib].each do |dir|
          so_file = "#{dir}/#{ruby_version[/^\d+\.\d+/]}/rmagick.so"
          if File.exists?(so_file)
            sh "#{prefix}-strip -S #{so_file}"
          end
        end
      end
    end
  end
end




require 'rake/testtask'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
end

task :test => :compile

if ENV['STYLE_CHECKS']
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
  task :default => [:test, :rubocop]
else
  task :default => :test
end

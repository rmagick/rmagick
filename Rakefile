require './lib/rmagick/version'
require 'fileutils'
desc "build and push gem, tag and push repo"
task "release" do
  sh("git diff --exit-code")
  abort "Git repo not clean" unless $?.success?
  sh("git diff-index --quiet --cached HEAD")
  abort "Git repo not commited" unless $?.success?
  version = Magick::VERSION
  # e.g. 2.13.3 becomes RMagick_2-13-3
  version_tag = "RMagick_#{version.gsub(".","-")}"
  # e.g. 2.13.3 becomes rmagick-2.13.3.gem
  gem_name = "rmagick-#{version}.gem"

  # build gem
  sh "gem build -V rmagick.gemspec"
  if $?.success?
    base = File.expand_path('..', __FILE__)
    FileUtils.mkdir_p(File.join(base, 'pkg'))
    FileUtils.mv(File.join(base, gem_name), 'pkg')
    # push gem
    sh "gem push #{File.join(base, 'pkg', gem_name)}"
    if $?.success?
      sh "git tag -a -m \"Version #{version}\" #{version_tag}"
      STDOUT.puts "Tagged #{version_tag}."
      sh "git push"
      sh "git push --tags"
    else
      abort "tagging aborted pushing gem failed"
    end

  else
    STDERR.puts "Could not build gem"
    exit $?.exitstatus
  end
end

desc "Release and build the legacy way"
task :legacy_release=> ["legacy:README.html", "legacy:extconf", "legacy:doc", "legacy:manifest"]

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

require 'rake/extensiontask'
require 'rake/testtask'

Rake::ExtensionTask.new('RMagick2') do |ext|
  ext.ext_dir = 'ext/RMagick'
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
end

task :test => :compile

task :default => :test

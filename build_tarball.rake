# Build the .gem file for an RMagick Release
# To use: cd to $HOME
# run:    rake -f path/to/build_tarball.rake clean
#         rake -f path/to/build_tarball.rake release=tag beta=whatever
#
# Specify the release as release=RMagick_x-y-z or nothing if release=HEAD
# Specify a beta Release as beta=beta1

require 'rubygems'
require 'redcloth'
require 'find'
require 'fileutils'
include FileUtils

# GIT_Tag is the CVS tag for this release. Dist_Directory is GIT_Tag,
# modified for use as a directory name.
if ENV.include?("release")
  GIT_Tag = ENV["release"]
  Dist_Directory = GIT_Tag.tr('_-','-.')
else
  GIT_Tag = "HEAD"
  Dist_Directory = "RMagick-0.0.0"
end


# RMagick_Version is just X.Y.Z
RMagick_Version = Dist_Directory.sub(/RMagick-/, "")

# RMagick_Version2 is X.Y.Z + "-beta1" if beta=beta1
RMagick_Version2 = RMagick_Version + (ENV.include?("beta") ? "-" + ENV["beta"] : "")

# Release is RMagick-X.Y.Z, plus "-beta1" if beta=beta1
Release = Dist_Directory + (ENV.include?("beta") ? "-" + ENV["beta"] : "")

README = "README.html"
MANIFEST = "ext/RMagick/MANIFEST"

# Change the version number placeholders in a file.
# Returns an array of lines from the file.
def reversion(name)
  now = Time.new
  now = now.strftime("%m/%d/%y")

  lines = File.readlines name
  lines.each do |line|
    line.gsub!(%r{0\.0\.0\$}, RMagick_Version2)
    line.gsub!(%r{0\.0\.0}, RMagick_Version)
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
  Dir.chdir(Dist_Directory) { reversion_file "ext/RMagick/extconf.rb" }
end

desc "Update gemspec version"
task :gemspec do
  Dir.chdir(Dist_Directory) { reversion_file "rmagick.gemspec" }
end

desc "Build README.txt from README.textile using RedCloth"
task "README.txt" do
  Dir.chdir Dist_Directory do
    reversion_file "README.textile"
    body = File.readlines "README.textile"
    body = RedCloth.new(body.join).to_html + "\n"
    File.open("README.txt", "w") { |f| f.write body }
  end
end

desc "Build README.html from README.txt"
task README => "README.txt" do
  puts "writing #{README}"
  Dir.chdir Dist_Directory do
    File.open(README, "w") do |html|
      html.write <<END_HTML_HEAD
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
  <head>
    <title>RMagick #{RMagick_Version2} README</title>
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
end

desc "Update versions in html files"
task :doc do
  Dir.chdir(File.join(Dist_Directory, "doc")) do
      FileList["*.html"].each { |d| reversion_file(d) }
  end
end

# Remove files we don't want in the tarball.
# Ensure files are not executable. (ref: bug #10080)
desc "Remove files we don't want in the .gem; ensure files are not executable"
task :fix_files do
  Dir.chdir Dist_Directory do
    rm_rf "test", :verbose => true
    rm "lib/rvg/to_c.rb", :verbose => true
    rm "README.textile", :verbose => true
    rm "README.txt", :verbose => true
    chmod 0644, FileList["doc/*.html", "doc/ex/*.rb", "doc/ex/images/*", "examples/*.rb"]
  end
end


desc "Build manifest"
task :manifest do
  now = Time.new
  now = now.strftime("%H:%M:%S %m/%d/%y")
  puts "generating #{MANIFEST}"

  Dir.chdir Dist_Directory do
    File.open(MANIFEST, "w") do |f|
      f.puts "MANIFEST for #{Release} - #{now}\n\n"
      Find.find('.') do |name|
        next if File.directory? name
        f.puts name[2..-1]    # remove leading "./"
      end
    end
  end
end

desc "Tag release"
task :export do
  cvsserver = ":ext:rmagick@rubyforge.org/var/cvs/rmagick"
  puts "!!!!!cvs -d#{cvsserver} export -r #{GIT_Tag} -d #{Dist_Directory} RMagick"
end

desc "Build files"
task :collateral => [README, :gemspec, :extconf, :doc]

GEM = Dist_Directory.downcase + ".gem"

desc "tag and build gem"
task :default => [:export, :collateral, :fix_files, :manifest] do
  Dir.chdir(Dist_Directory) do
    sh "gem build rmagick.gemspec"
    mv GEM, "../", :verbose => true
  end
end

desc "Remove #{Dist_Directory} and #{GEM}"
task :clean do
  rm_rf Dist_Directory, :verbose => true
  rm_rf GEM, :verbose => true
end

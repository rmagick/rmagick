# note, there are other, legacy tasks in build_tarball.rake
# thate currently are run by e.g.
#   rake -f build_tarball.rake clean release=RMagick_2-13-1
#   rake -f build_tarball.rake release=RMagick_2-13-1
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
      abort "tagging abd pushing gem failed"
    end

  else
    STDERR.puts "Could not build gem"
    exit $?.exitstatus
  end
end

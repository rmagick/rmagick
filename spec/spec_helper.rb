require 'rmagick'

root_dir = File.expand_path('..', __dir__)
IMAGES_DIR = File.join(root_dir, 'doc/ex/images')
SUPPORT_DIR = File.join(root_dir, 'spec', 'support')

def supported_after(version)
  magick_lib_version = Magick::Magick_version.split[1].split('-').first
  :skip if Gem::Version.new(magick_lib_version) < Gem::Version.new(version)
end

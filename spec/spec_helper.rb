require 'rmagick'

root_dir = File.expand_path('..', __dir__)
IMAGES_DIR = File.join(root_dir, 'doc/ex/images')
SUPPORT_DIR = File.join(root_dir, 'spec', 'support')

def supported_after(version)
  :skip if Gem::Version.new(Magick::IMAGEMAGICK_VERSION) < Gem::Version.new(version)
end

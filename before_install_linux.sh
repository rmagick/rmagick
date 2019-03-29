set -euo pipefail

sudo apt-get update

# remove all existing imagemagick related packages
sudo apt-get autoremove -y imagemagick* libmagick* --purge

# install build tools, ImageMagick delegates
sudo apt-get install -y build-essential libx11-dev libxext-dev zlib1g-dev \
  liblcms2-dev libpng-dev libjpeg-dev libfreetype6-dev libxml2-dev \
  libtiff5-dev libwebp-dev vim ghostscript ccache

if [ ! -d /usr/include/freetype ]; then
  # If `/usr/include/freetype` is not existed, ImageMagick 6.7 configuration fails about Freetype.
  sudo ln -sf /usr/include/freetype2 /usr/include/freetype
fi

if [ -v IMAGEMAGICK_VERSION ]; then
  if wget https://github.com/ImageMagick/ImageMagick/archive/${IMAGEMAGICK_VERSION}.tar.gz; then
    tar -xzf ImageMagick-${IMAGEMAGICK_VERSION}.tar.gz
  else
    wget http://www.imagemagick.org/download/releases/ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz
    tar -xf ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz
  fi
  cd ImageMagick-${IMAGEMAGICK_VERSION}
else
  echo "you must specify an ImageMagick version."
  echo "example: 'IMAGEMAGICK_VERSION=6.8.9-10 bash ./before_install_linux.sh'"
  exit 1
fi

options="--with-magick-plus-plus=no --disable-docs"
if [ -v CONFIGURE_OPTIONS ]; then
  options="${CONFIGURE_OPTIONS} $options"
fi

CC="ccache cc" CXX="ccache c++" ./configure --prefix=/usr $options

make -j
sudo make install -j
cd ..
sudo ldconfig

gem install bundler

set +u

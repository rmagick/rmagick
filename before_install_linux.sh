set -euo pipefail

sudo apt-get update

# remove all existing imagemagick related packages
sudo apt-get autoremove -y imagemagick* libmagick* --purge

# install build tools, ImageMagick delegates
sudo apt-get install -y build-essential libx11-dev libxext-dev zlib1g-dev \
  liblcms2-dev libpng-dev libjpeg-dev libfreetype6-dev libxml2-dev \
  libtiff5-dev vim ghostscript ccache

if [ -v IMAGEMAGICK_VERSION ]; then
  wget http://www.imagemagick.org/download/releases/ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz
  tar -xf ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz
  cd ImageMagick-${IMAGEMAGICK_VERSION}
else
  echo "you must specify an ImageMagick version."
  echo "example: 'IMAGEMAGICK_VERSION=6.8.9-10 bash ./before_install_linux.sh'"
  exit 1
fi

if [ -v CONFIGURE_OPTIONS ]; then
  CC="ccache cc" CXX="ccache c++" ./configure --prefix=/usr $CONFIGURE_OPTIONS
else
  CC="ccache cc" CXX="ccache c++" ./configure --prefix=/usr
fi

make
sudo make install
cd ..
sudo ldconfig

gem install bundler

set +u

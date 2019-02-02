sudo apt-get update

# remove all existing imagemagick related packages
sudo apt-get autoremove -y imagemagick* libmagick* --purge

# install build tools, ImageMagick delegates
sudo apt-get install -y build-essential libx11-dev libxext-dev zlib1g-dev \
  liblcms2-dev libpng-dev libjpeg-dev libfreetype6-dev libxml2-dev \
  libtiff5-dev vim ghostscript ccache

case $IMAGEMAGICK_VERSION in
    latest)
        wget http://www.imagemagick.org/download/ImageMagick.tar.xz
        tar -xf ImageMagick.tar.xz
        cd ImageMagick-*
    ;;
    *)
        wget http://www.imagemagick.org/download/releases/ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz
        tar -xf ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz
        cd ImageMagick-${IMAGEMAGICK_VERSION}
    ;;
esac
CC="ccache cc" CXX="ccache c++" ./configure --prefix=/usr $CONFIGURE_OPTIONS
make
sudo make install
cd ..
sudo ldconfig

gem install bundler -v 1.17.3

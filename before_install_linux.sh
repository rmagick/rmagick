dpkg --list imagemagick
sudo apt-get update
sudo apt-get remove imagemagick
sudo apt-get install build-essential libx11-dev libxext-dev zlib1g-dev libpng12-dev libjpeg-dev libfreetype6-dev libxml2-dev
sudo apt-get build-dep imagemagick
wget http://www.imagemagick.org/download/releases/ImageMagick-${IMAGEMAGICK_VERSION}.tar.gz
tar -xzvf ImageMagick-${IMAGEMAGICK_VERSION}.tar.gz
cd ImageMagick-${IMAGEMAGICK_VERSION}
./configure --prefix=/usr $CONFIGURE_OPTIONS
sudo make install
cd ..
sudo ldconfig

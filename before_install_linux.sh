dpkg --list imagemagick
sudo apt-get update
sudo apt-get remove -y imagemagick
sudo apt-get install -y build-essential libx11-dev libxext-dev zlib1g-dev libpng12-dev libjpeg-dev libfreetype6-dev libxml2-dev
sudo apt-get build-dep -y imagemagick
case $IMAGEMAGICK_VERSION in
    latest)
        wget http://www.imagemagick.org/download/ImageMagick.tar.gz
        tar -xzvf ImageMagick.tar.gz
        cd ImageMagick-*
    ;;
    *)
        wget http://www.imagemagick.org/download/releases/ImageMagick-${IMAGEMAGICK_VERSION}.tar.gz
        tar -xzvf ImageMagick-${IMAGEMAGICK_VERSION}.tar.gz
        cd ImageMagick-${IMAGEMAGICK_VERSION}
    ;;
esac
./configure --prefix=/usr $CONFIGURE_OPTIONS
sudo make install
cd ..
sudo ldconfig

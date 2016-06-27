dpkg --list imagemagick
sudo apt-get update
sudo apt-get remove -y imagemagick
sudo apt-get install -y build-essential libx11-dev libxext-dev zlib1g-dev libpng12-dev libjpeg-dev libfreetype6-dev libxml2-dev
sudo apt-get build-dep -y imagemagick
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
./configure --prefix=/usr $CONFIGURE_OPTIONS
sudo make install
cd ..
sudo ldconfig

# Fix for "NoMethodError: undefined method `spec' for nil:NilClass" on Travis
# According to https://twitter.com/apotonick/status/678331744311836672
gem install bundler

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

if [[ $TRAVIS_RUBY_VERSION =~ ^1.8 ]]; then
    echo "Set the stack size to unlimited to avoid segfault for Ruby 1.8"
    ulimit -s unlimited
fi

# Fixes this error:
# NoMethodError: undefined method `spec' for nil:NilClass
# Travis uses Bundler 1.7.6 by default and it has this bug
# https://github.com/rubygems/rubygems/issues/1419
gem install bundler

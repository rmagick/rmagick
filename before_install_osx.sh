#!/usr/bin/env bash

set -euox pipefail

brew install freetype gs

wget http://www.imagemagick.org/download/releases/ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz
tar -xf ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz
cd ImageMagick-${IMAGEMAGICK_VERSION}

pwd
ls

./configure
make
sudo make install
cd ..

gem install bundler

set +u

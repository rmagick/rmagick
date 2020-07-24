#!/usr/bin/env bash

set -euox pipefail

gem install bundler

if [ -v STYLE_CHECKS ]; then
  set +ux
  exit 0
fi

if [ ! -v IMAGEMAGICK_VERSION ]; then
  echo "you must specify an ImageMagick version."
  echo "example: 'IMAGEMAGICK_VERSION=6.8.9-10 bash ./before_install_osx.sh'"
  exit 1
fi

export HOMEBREW_NO_AUTO_UPDATE=true
brew install wget pkg-config ghostscript freetype jpeg little-cms2 libomp libpng libtiff liblqr libtool libxml2 zlib webp

export LDFLAGS="-L/usr/local/opt/libxml2/lib -L/usr/local/opt/zlib/lib"
export CPPFLAGS="-I/usr/local/opt/libxml2/include/libxml2 -I/usr/local/opt/zlib/include"

project_dir=$(pwd)
build_dir="${project_dir}/build-ImageMagick/ImageMagick-${IMAGEMAGICK_VERSION}"
if [ -v CONFIGURE_OPTIONS ]; then
  build_dir="${build_dir}-${CONFIGURE_OPTIONS}"
fi

build_imagemagick() {
  mkdir -p build-ImageMagick

  version=(${IMAGEMAGICK_VERSION//./ })
  wget "https://imagemagick.org/download/releases/ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz"
  tar -xf "ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz"
  rm "ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz"
  mv "ImageMagick-${IMAGEMAGICK_VERSION}" "${build_dir}"

  options="--with-magick-plus-plus=no --disable-docs"
  if [ -v CONFIGURE_OPTIONS ]; then
    options="${CONFIGURE_OPTIONS} ${options}"
  fi

  cd "${build_dir}"
  ./configure --prefix=/usr/local "${options}"
  make -j
}

if [ ! -d "${build_dir}" ]; then
  build_imagemagick
fi

cd "${build_dir}"
make install -j
cd "${project_dir}"

set +ux

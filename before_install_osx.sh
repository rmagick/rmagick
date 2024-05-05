#!/usr/bin/env bash

set -euox pipefail

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
brew uninstall --force imagemagick imagemagick@6
brew install wget ghostscript freetype libtool jpeg jpeg-xl little-cms2 openexr libomp libpng libtiff liblqr zlib webp zstd

export LDFLAGS="-L$(brew --prefix jpeg)/lib -I$(brew --prefix jpeg-xl)/lib -L$(brew --prefix little-cms2)/lib -L$(brew --prefix openexr)/lib -L$(brew --prefix libomp)/lib -L$(brew --prefix libpng)/lib -L$(brew --prefix libtiff)/lib -L$(brew --prefix liblqr)/lib -L$(brew --prefix zlib)/lib -L$(brew --prefix webp)/lib -L$(brew --prefix zstd)/lib"
export CPPFLAGS="-I$(brew --prefix jpeg)/include -I$(brew --prefix jpeg-xl)/include -I$(brew --prefix openexr)/include/OpenEXR -I$(brew --prefix libtiff)/include -I$(brew --prefix zlib)/include -I$(brew --prefix zstd)/include -I$(brew --prefix glib)/include/glib-2.0 -I$(brew --prefix glib)/lib/glib-2.0/include"

project_dir=$(pwd)
build_dir="${project_dir}/build-ImageMagick/ImageMagick-${IMAGEMAGICK_VERSION}"
if [ -v CONFIGURE_OPTIONS ]; then
  build_dir="${build_dir}-${CONFIGURE_OPTIONS}"
fi

build_imagemagick() {
  mkdir -p build-ImageMagick

  version=(${IMAGEMAGICK_VERSION//./ })
  wget "https://imagemagick.org/archive/releases/ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz"
  tar -xf "ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz"
  rm "ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz"
  mv "ImageMagick-${IMAGEMAGICK_VERSION}" "${build_dir}"

  options="--with-magick-plus-plus=no --disable-docs"
  if [ -v CONFIGURE_OPTIONS ]; then
    options="${CONFIGURE_OPTIONS} ${options}"
  fi

  cd "${build_dir}"
  ./configure \
    --prefix=/usr/local \
    "${options}" \
    --with-gs-font-dir=/opt/homebrew/share/ghostscript/fonts \
    --without-raw
  make -j
}

if [ ! -d "${build_dir}" ]; then
  build_imagemagick
fi

cd "${build_dir}"
sudo make install -j
cd "${project_dir}"

set +ux

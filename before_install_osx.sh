#!/usr/bin/env bash

set -euox pipefail

gem install bundler -v 2.3.26 # Bundler 2.4.x has dropped support for Ruby 2.3

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
brew install wget ghostscript freetype jpeg little-cms2 openexr libomp libpng libtiff liblqr libtool zlib webp

export LDFLAGS="-L$(brew --prefix libxml2)/lib -L$(brew --prefix zlib)/lib -L$(brew --prefix glib)/lib -L$(brew --prefix openexr)/lib"
export CPPFLAGS="-I$(brew --prefix libxml2)/include -I$(brew --prefix zlib)/include -I$(brew --prefix glib)/include/glib-2.0 -I$(brew --prefix glib)/lib/glib-2.0/include -I$(brew --prefix openexr)/include/OpenEXR"

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
  ./configure --prefix=/usr/local "${options}" --without-raw
  make -j
}

if [ ! -d "${build_dir}" ]; then
  build_imagemagick
fi

cd "${build_dir}"
make install -j
cd "${project_dir}"

set +ux

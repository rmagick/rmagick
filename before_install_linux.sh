#!/usr/bin/env bash

set -euox pipefail

if [ -v STYLE_CHECKS ]; then
  set +ux
  exit 0
fi

if [ ! -v IMAGEMAGICK_VERSION ]; then
  echo "you must specify an ImageMagick version."
  echo "example: 'IMAGEMAGICK_VERSION=6.9.13-43 bash ./before_install_linux.sh'"
  exit 1
fi

sudo apt-get update -y

# remove all existing imagemagick related packages
sudo apt-get autoremove -y imagemagick* libmagick* --purge

# install build tools, ImageMagick delegates
sudo apt-get install -y build-essential libx11-dev libxext-dev zlib1g-dev \
  liblcms2-dev libpng-dev libjpeg-dev libfreetype6-dev \
  libtiff5-dev libwebp-dev liblqr-1-0-dev libglib2.0-dev gsfonts ghostscript

project_dir=$(pwd)
build_dir="${project_dir}/build-ImageMagick/ImageMagick-${IMAGEMAGICK_VERSION}"
if [ -v CONFIGURE_OPTIONS ]; then
  build_dir="${build_dir}-${CONFIGURE_OPTIONS}"
fi

build_imagemagick() {
  mkdir -p build-ImageMagick

  version=(${IMAGEMAGICK_VERSION//./ })
  repo="ImageMagick/ImageMagick"
  archive_dir="ImageMagick-${IMAGEMAGICK_VERSION}"
  if [ "${version[0]}" = "6" ]; then
    repo="ImageMagick/ImageMagick6"
    archive_dir="ImageMagick6-${IMAGEMAGICK_VERSION}"
  fi

  wget -O "ImageMagick-${IMAGEMAGICK_VERSION}.tar.gz" "https://github.com/${repo}/archive/refs/tags/${IMAGEMAGICK_VERSION}.tar.gz"
  tar -xf "ImageMagick-${IMAGEMAGICK_VERSION}.tar.gz"
  rm "ImageMagick-${IMAGEMAGICK_VERSION}.tar.gz"
  mv "${archive_dir}" "${build_dir}"

  options="--with-magick-plus-plus=no --disable-docs"
  if [ -v CONFIGURE_OPTIONS ]; then
    options="${CONFIGURE_OPTIONS} ${options}"
  fi

  cd "${build_dir}"
  ./configure --prefix=/usr "${options}"
  make -j$(nproc)
}

if [ ! -d "${build_dir}" ]; then
  build_imagemagick
fi

cd "${build_dir}"
sudo make install -j$(nproc)
cd "${project_dir}"

sudo ldconfig

set +ux

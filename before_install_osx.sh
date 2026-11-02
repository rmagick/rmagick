#!/usr/bin/env bash

set -euox pipefail

if [ -z "${IMAGEMAGICK_VERSION:-}" ]; then
  echo "you must specify an ImageMagick version."
  echo "example: 'IMAGEMAGICK_VERSION=6.9.13-43 bash ./before_install_osx.sh'"
  exit 1
fi

export HOMEBREW_NO_AUTO_UPDATE=true
brew uninstall --force imagemagick imagemagick@6
brew install wget ghostscript freetype libtool jpeg jpeg-xl little-cms2 openexr libomp libpng libtiff liblqr zlib webp zstd glib xz harfbuzz

export LDFLAGS="-L$(brew --prefix jpeg)/lib -L$(brew --prefix jpeg-xl)/lib -L$(brew --prefix little-cms2)/lib -L$(brew --prefix openexr)/lib -L$(brew --prefix libomp)/lib -L$(brew --prefix libpng)/lib -L$(brew --prefix libtiff)/lib -L$(brew --prefix liblqr)/lib -L$(brew --prefix zlib)/lib -L$(brew --prefix webp)/lib -L$(brew --prefix zstd)/lib -L$(brew --prefix xz)/lib -L$(brew --prefix harfbuzz)/lib"
export CPPFLAGS="-I$(brew --prefix jpeg)/include -I$(brew --prefix jpeg-xl)/include -I$(brew --prefix openexr)/include/OpenEXR -I$(brew --prefix libtiff)/include -I$(brew --prefix zlib)/include -I$(brew --prefix zstd)/include -I$(brew --prefix glib)/include/glib-2.0 -I$(brew --prefix glib)/lib/glib-2.0/include -I$(brew --prefix xz)/include -I$(brew --prefix harfbuzz)/include"

project_dir=$(pwd)

options=(
  --with-magick-plus-plus=no
  --disable-docs
  --with-gs-font-dir="$(brew --prefix)/share/ghostscript/fonts"
  --without-raw
)
if [ -n "${CONFIGURE_OPTIONS:-}" ]; then
  read -r -d '' -a extra_options <<< "${CONFIGURE_OPTIONS}" || true
  options+=(${extra_options[@]+"${extra_options[@]}"})
fi
options_hash=$(printf '%s\0' "${options[@]}" | cksum | cut -d ' ' -f 1)
build_dir="${project_dir}/build-ImageMagick/ImageMagick-${IMAGEMAGICK_VERSION}-${options_hash}"

build_imagemagick() {
  rm -rf "${build_dir}"
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

  cd "${build_dir}"
  ./configure --prefix=/usr/local "${options[@]}"
  make -j$(sysctl -n hw.logicalcpu)
  touch "${build_dir}/.build-complete"
}

if [ ! -f "${build_dir}/.build-complete" ]; then
  build_imagemagick
fi

cd "${build_dir}"
sudo make install -j$(sysctl -n hw.logicalcpu)
cd "${project_dir}"

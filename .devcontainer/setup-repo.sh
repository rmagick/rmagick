#!/bin/bash
set -e

apt-get update
apt-get install sudo

bash /workspaces/rmagick/before_install_linux.sh

cd /workspaces/rmagick
bundle install --path=vendor/bundle --jobs 4 --retry 3

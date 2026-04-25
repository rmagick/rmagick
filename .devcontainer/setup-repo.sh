#!/bin/bash
set -e

apt-get update -y
apt-get install -y sudo

bash /workspaces/rmagick/before_install_linux.sh

cd /workspaces/rmagick
bundle install --jobs 4 --retry 3

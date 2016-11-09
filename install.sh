#! /bin/bash

set -e

install_path=/usr/local/bin

echo "Building Jenny"
MIX_ENV=prod mix do deps.get, escript.build

echo "Installing Jenny to $install_path"
mv jenny $install_path

echo "Done"

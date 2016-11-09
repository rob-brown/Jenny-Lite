#! /bin/bash

set -e

uninstall_path=/usr/local/bin/jenny

echo "Uninstalling Jenny from $uninstall_path"
rm -f $uninstall_path

echo "Done"

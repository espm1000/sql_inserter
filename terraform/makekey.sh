#!/bin/bash

set -e

if [ "$1" == "--clear" ]; then
  rm -v -- *_key*
  exit
fi

if [ ! -d "resources/" ]; then
  echo "Creating sec dir..."
  mkdir resources/
fi

echo "Creating key pair.."
ssh-keygen -t rsa -b 4096 -f ./resources/temp_key -q -N ""

#!/bin/bash

# Make sure lcms is installed
pkg-config --exists lcms2 cairo
HAS_LIBS=$?
if [ "$HAS_LIBS" != "0" ]
then
  echo "lcms2 and cairo must be installed for verification"
  echo "Mac: sudo port install cairo lcms"
  exit
fi

# Compile
make transform-image compare-image
HAS_COMPILED=$?
if [ "$HAS_COMPILED" != "0" ]
then
  echo "Failed to compiled"
  exit
fi

./bin/test.sh && open tmp/overview.html

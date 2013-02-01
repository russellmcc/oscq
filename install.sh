#!/bin/bash
npm install .

# fix up dependencies to use nw-gyp
command -v nw-gyp >/dev/null 2>&1 || { echo >&2 "I require nw-gyp but it's not installed.  executing sudo npm install -g nw-gyp."; sudo npm install -g nw-gyp; }

cd node_modules/mdns
rm -rf build
nw-gyp configure --target=0.4.0 --arch=i386 -r
nw-gyp build
cd ../osc-min/node_modules/binpack
nw-gyp configure --target=0.4.0 --arch=i386 -r
nw-gyp build
cd ../../../

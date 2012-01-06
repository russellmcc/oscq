#!/bin/bash
git submodule init
git submodule update
cd oscq.app/Contents/Resources/app/
npm install .
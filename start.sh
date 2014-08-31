#!/bin/sh

git pull
bundle install
pod install

open NativeBridgeBenchmark.xcworkspace

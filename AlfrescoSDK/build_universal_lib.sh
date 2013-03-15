#!/bin/bash

# ensure the universal library is built
BUILD_UNIVERSAL_LIB='TRUE'
export BUILD_UNIVERSAL_LIB

if [[ "$1" == "Debug" ]] ; then
   BUILD_CONFIG=Debug
   echo "Building debug version of universal library..."
else
   BUILD_CONFIG=Release
   echo "Building release version of universal library..."
fi

xcodebuild -project AlfrescoSDK.xcodeproj -target AlfrescoSDK -configuration $BUILD_CONFIG clean build

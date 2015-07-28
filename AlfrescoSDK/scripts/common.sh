#!/bin/bash

# Copyright (C) 2005-2015 Alfresco Software Limited.
#
# This file is part of the Alfresco Mobile SDK.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

if [ -z "$ALFRESCO_SDK_SCRIPT" ]; then

   # -----------------------------------------------------------------------------
   # Script Parameters
   #
   BUILD_CONFIGURATION=Release
   LIBRARY_SUFFIX=""
   
   for param in $*
   do
      if [[ "$param" == "Debug" ]] ; then
         BUILD_CONFIGURATION=Debug
         LIBRARY_SUFFIX="-debug"
      fi
   done

   # Xcode build tools
   test -n "$XCODEBUILD"   || XCODEBUILD=$(which xcodebuild)
   test -n "$LIPO"         || LIPO=$(which lipo)
   test -n "$APPLEDOC"     || APPLEDOC=$(which appledoc)
   

   # ---------------------------------------------------------------------------
   # Build environment variables
   #

   ## Common

   # The directory containing this script
   # We need to go there and use pwd so these are all absolute paths
   pushd "$(dirname "$BASH_SOURCE[0]")" >/dev/null
   ALFRESCO_SDK_SCRIPT=$(pwd)
   popd >/dev/null

   # The root directory where the Alfresco SDK for iOS is cloned
   ALFRESCO_SDK_ROOT="$(dirname "$ALFRESCO_SDK_SCRIPT")"
   cd "$ALFRESCO_SDK_ROOT"

   # Path to source files for Alfresco SDK
   ALFRESCO_SDK_SRC=$ALFRESCO_SDK_ROOT/AlfrescoSDK

   # The directory where the target is built
   ALFRESCO_SDK_BUILD=$ALFRESCO_SDK_ROOT/build

   # The name of the Alfresco SDK
   ALFRESCO_SDK_PRODUCT_NAME=AlfrescoSDK

   # Extracts the Alfresco SDK Version from the project's xcconfig file.
   ALFRESCO_SDK_VERSION=$(sed -ne '/^ALFRESCO_SDK_VERSION=/s/.*=\([\^]*\)/\1/p' "$ALFRESCO_SDK_SRC/AlfrescoSDK.xcconfig")
   progress_message "Alfresco SDK Version detected: $ALFRESCO_SDK_VERSION"

   ## iOS

   # The name of the Alfresco SDK for iOS
   ALFRESCO_IOS_SDK_PRODUCT_NAME=${ALFRESCO_SDK_PRODUCT_NAME}-iOS

   # The name of the Alfresco SDK for iOS static library
   ALFRESCO_IOS_SDK_LIBRARY_NAME=lib"$ALFRESCO_IOS_SDK_PRODUCT_NAME"v"$ALFRESCO_SDK_VERSION""$LIBRARY_SUFFIX".a

   # The path to the universal static library for iOS
   ALFRESCO_IOS_SDK_UNIVERSAL_LIBRARY_PATH=$ALFRESCO_SDK_BUILD/$BUILD_CONFIGURATION-universal
   ALFRESCO_IOS_SDK_UNIVERSAL_LIBRARY=$ALFRESCO_IOS_SDK_UNIVERSAL_LIBRARY_PATH/$ALFRESCO_IOS_SDK_LIBRARY_NAME

   # The path to the built Alfresco SDK for iOS .framework
   ALFRESCO_IOS_SDK_FRAMEWORK=$ALFRESCO_SDK_BUILD/$ALFRESCO_IOS_SDK_PRODUCT_NAME.framework

   ## Mac OS X

   # The name of the Alfresco SDK for OS X
   ALFRESCO_OSX_SDK_PRODUCT_NAME=${ALFRESCO_SDK_PRODUCT_NAME}-OSX

   # The name of the Alfresco SDK for OS X library
   ALFRESCO_OSX_SDK_LIBRARY_NAME=lib"$ALFRESCO_OSX_SDK_PRODUCT_NAME"v"$ALFRESCO_SDK_VERSION""$LIBRARY_SUFFIX".a

   # The path to the universal static library for OSX
   ALFRESCO_OSX_SDK_LIBRARY_PATH=$ALFRESCO_SDK_BUILD/$BUILD_CONFIGURATION-macosx
   ALFRESCO_OSX_SDK_LIBRARY=$ALFRESCO_OSX_SDK_LIBRARY_PATH/$ALFRESCO_OSX_SDK_LIBRARY_NAME

   # The path to the built Alfresco SDK for OS X .framework
   ALFRESCO_OSX_SDK_FRAMEWORK=$ALFRESCO_SDK_BUILD/$ALFRESCO_OSX_SDK_PRODUCT_NAME.framework

   ## Documentation

   # The name of the docset
   ALFRESCO_SDK_DOCSET_NAME=com.alfresco.AlfrescoSDK.docset

   # The directory where the docset is built
   ALFRESCO_SDK_DOCSET_BUILD=$ALFRESCO_SDK_BUILD/Help

   ## Packaging

   ALFRESCO_SDK_PACKAGE=$ALFRESCO_SDK_BUILD/Package
   VERSION_SUFFIX_ZIP=$ALFRESCO_SDK_VERSION"$LIBRARY_SUFFIX".zip

   # Package names - libraries and frameworks
   ALFRESCO_IOS_SDK_LIBRARY_ZIP=$ALFRESCO_SDK_PACKAGE/alfresco-ios-sdk-library-$VERSION_SUFFIX_ZIP
   ALFRESCO_IOS_SDK_FRAMEWORK_ZIP=$ALFRESCO_SDK_PACKAGE/alfresco-ios-sdk-framework-$VERSION_SUFFIX_ZIP
   ALFRESCO_OSX_SDK_LIBRARY_ZIP=$ALFRESCO_SDK_PACKAGE/alfresco-osx-sdk-library-$VERSION_SUFFIX_ZIP
   ALFRESCO_OSX_SDK_FRAMEWORK_ZIP=$ALFRESCO_SDK_PACKAGE/alfresco-osx-sdk-framework-$VERSION_SUFFIX_ZIP

   # Package name - documentation
   ALFRESCO_SDK_DOCSET_ZIP=$ALFRESCO_SDK_PACKAGE/alfresco-sdk-docset-$ALFRESCO_SDK_VERSION.zip


   # ---------------------------------------------------------------------------
   # Build environment functions
   #

   # Echoes a progress message to stderr
   function progress_message() {
      echo "$@" >&2
   }

   # Call this when there is an error. This does not return.
   function die() {
      echo ""
      echo "FATAL: $*" >&2
      exit 1
   }

   # Uses xcodebuild to build a given target, platform and SDK combination
   #
   # Arguments:
   #    1: target, e.g. "AlfrescoSDK-iOS" or "AlfrescoSDK-OSX"
   #    2: platform, i.e. "iphoneos" or "iphonesimulator"
   #    3: baseSDK, e.g. "7.0" or "" for latest
   function xcode_build_target() {
      $XCODEBUILD \
         -project $ALFRESCO_SDK_PRODUCT_NAME.xcodeproj \
         -target ${1} \
         -sdk ${2}${3} \
         -configuration $BUILD_CONFIGURATION \
         RUN_CLANG_STATIC_ANALYZER=NO \
         ONLY_ACTIVE_ARCH=NO \
         TARGET_BUILD_DIR="$ALFRESCO_SDK_BUILD/$BUILD_CONFIGURATION-${2}" \
         BUILT_PRODUCTS_DIR="$ALFRESCO_SDK_BUILD/$BUILD_CONFIGURATION-${2}" \
         SYMROOT="$ALFRESCO_SDK_BUILD" \
         clean build \
         || die "XCode build failed for configuration: $BUILD_CONFIGURATION."
   }

fi

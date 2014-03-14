#!/bin/bash

# Copyright (C) 2005-2014 Alfresco Software Limited.
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

. ${ALFRESCO_SDK_SCRIPT:-$(dirname $0)}/common.sh

# -----------------------------------------------------------------------------
# Compile binaries 
#
progress_message "Compiling $ALFRESCO_SDK_PRODUCT_NAME - $BUILD_CONFIGURATION configuration"

test -x "$XCODEBUILD" || die 'Could not find xcodebuild in $PATH'
test -x "$LIPO" || die 'Could not find lipo in $PATH'

test -d $ALFRESCO_SDK_BUILD \
   || mkdir -p $ALFRESCO_SDK_BUILD \
   || die "Could not create directory $ALFRESCO_SDK_BUILD"

#
# Arguments:
#    platform, i.e. "iphoneos" or "iphonesimulator"
#    baseSDK, i.e. "7.0"
function xcode_build_target() {
   $XCODEBUILD \
      -project $ALFRESCO_SDK_PRODUCT_NAME.xcodeproj \
      -target $ALFRESCO_SDK_PRODUCT_NAME \
      -sdk ${1}${2} \
      -configuration $BUILD_CONFIGURATION \
      RUN_CLANG_STATIC_ANALYZER=NO \
      ONLY_ACTIVE_ARCH=NO \
      TARGET_BUILD_DIR=$ALFRESCO_SDK_BUILD/$BUILD_CONFIGURATION-${1} \
      BUILT_PRODUCTS_DIR=$ALFRESCO_SDK_BUILD/$BUILD_CONFIGURATION-${1} \
      SYMROOT=$ALFRESCO_SDK_BUILD \
      clean build \
      || die "XCode build failed for configuration: $BUILD_CONFIGURATION."
}

xcode_build_target "iphonesimulator" ""
xcode_build_target "iphoneos" ""


# -----------------------------------------------------------------------------
# Universal library
#
progress_message "Building universal library for $ALFRESCO_SDK_PRODUCT_NAME - $BUILD_CONFIGURATION configuration"

mkdir -p $(dirname $ALFRESCO_SDK_UNIVERSAL_LIBRARY)

$LIPO \
   -create \
      $ALFRESCO_SDK_BUILD/$BUILD_CONFIGURATION-iphoneos/$ALFRESCO_SDK_LIBRARY_NAME \
      $ALFRESCO_SDK_BUILD/$BUILD_CONFIGURATION-iphonesimulator/$ALFRESCO_SDK_LIBRARY_NAME \
   -output $ALFRESCO_SDK_UNIVERSAL_LIBRARY \
   || die "lipo failed - could not create universal static library"

cd $ALFRESCO_SDK_ROOT

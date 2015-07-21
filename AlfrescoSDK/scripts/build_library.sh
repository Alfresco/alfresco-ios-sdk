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

. ${ALFRESCO_SDK_SCRIPT:-$(dirname $0)}/common.sh

# -----------------------------------------------------------------------------
# Compile binaries
#
progress_message "Compiling $ALFRESCO_SDK_PRODUCT_NAME - $BUILD_CONFIGURATION configuration"

test -x "$XCODEBUILD" || die 'Could not find xcodebuild in $PATH'
test -x "$LIPO" || die 'Could not find lipo in $PATH'

test -d "$ALFRESCO_SDK_BUILD" \
   || mkdir -p "$ALFRESCO_SDK_BUILD" \
   || die "Could not create directory $ALFRESCO_SDK_BUILD"

cd "$ALFRESCO_SDK_ROOT"

#
# Build iOS Library
#
xcode_build_target "$ALFRESCO_IOS_SDK_PRODUCT_NAME" "iphonesimulator" ""
xcode_build_target "$ALFRESCO_IOS_SDK_PRODUCT_NAME" "iphoneos" ""


# -----------------------------------------------------------------------------
# Universal library
#
progress_message "Building universal library for $ALFRESCO_SDK_PRODUCT_NAME - $BUILD_CONFIGURATION configuration"

ALFRESCO_IOS_SDK_UNIVERSAL_LIBRARY_PATH="$(dirname "$ALFRESCO_IOS_SDK_UNIVERSAL_LIBRARY")"
test -d $ALFRESCO_IOS_SDK_UNIVERSAL_LIBRARY_PATH || mkdir -p "$ALFRESCO_IOS_SDK_UNIVERSAL_LIBRARY_PATH" || die "Could not create directory $ALFRESCO_IOS_SDK_UNIVERSAL_LIBRARY_PATH"

$LIPO \
   -create \
      "$ALFRESCO_SDK_BUILD/$BUILD_CONFIGURATION-iphoneos/$ALFRESCO_IOS_SDK_LIBRARY_NAME" \
      "$ALFRESCO_SDK_BUILD/$BUILD_CONFIGURATION-iphonesimulator/$ALFRESCO_IOS_SDK_LIBRARY_NAME" \
   -output "$ALFRESCO_IOS_SDK_UNIVERSAL_LIBRARY" \
   || die "lipo failed - could not create universal static library"


cp -r \
   "$ALFRESCO_SDK_BUILD/$BUILD_CONFIGURATION-iphoneos/include" \
   "$ALFRESCO_IOS_SDK_UNIVERSAL_LIBRARY_PATH/" \
   || die "Error copying headers for universal library"

progress_message "**BUILD SUCCEEDED** - Created iOS universal library at $ALFRESCO_IOS_SDK_UNIVERSAL_LIBRARY_PATH"


#
# Build OS X Library
#
progress_message "Building OS X library for $ALFRESCO_SDK_PRODUCT_NAME - $BUILD_CONFIGURATION configuration"

xcode_build_target "$ALFRESCO_OSX_SDK_PRODUCT_NAME" "macosx" ""

progress_message "**BUILD SUCCEEDED** - Created Mac OS X library at $(dirname "$ALFRESCO_OSX_SDK_LIBRARY")"

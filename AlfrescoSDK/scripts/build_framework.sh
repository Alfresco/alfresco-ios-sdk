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
# Universal library
#
. "$ALFRESCO_SDK_SCRIPT/build_library.sh" "$BUILD_CONFIGURATION" \
   || die "Static library failed to build."

#
# params
#    target name - e.g. "AlfrescoSDK-iOS" or "AlfrescoSDK-OSX"
#    library location - e.g. /Users/[username]/AlfrescoSDK-iOSv1.0.a
#    framework name - e.g. AlfrescoSDK-iOS.framework
#    framework build path - e.g. /Users/[username]/AlfrescoSDK-iOS.framework
#
function build_framework() {
  # local vars
  local framework_target=${1}
  local framework_library_location=${2}
  local framework_name=${3}
  local framework_path=${4}
  local framework_library_header_root="$(dirname "$framework_library_location")"

  echo "PATH:$framework_path NAME:$framework_name TARGET:$framework_target Location:$framework_library_location"

  # -----------------------------------------------------------------------------
  # Build .framework folder structure
  #
  progress_message "Building $framework_name"

  \rm -rf "$framework_path"
  mkdir "$framework_path" \
     || die "Could not create directory $framework_path"
  mkdir "$framework_path/Versions"
  mkdir "$framework_path/Versions/A"
  mkdir "$framework_path/Versions/A/Headers"
  mkdir "$framework_path/Versions/A/Resources"

  \cp \
     "$ALFRESCO_SDK_SRC/Framework/Resources/"* \
     "$framework_path/Versions/A/Resources" \
     || die "Error building framework while copying Resources"
  \cp \
     "$framework_library_header_root/include/$framework_target/"*.h \
     "$framework_path/Versions/A/Headers" \
     || die "Error building framework while copying SDK headers"
  \cp \
     "$framework_library_location" \
     "$framework_path/Versions/A/$framework_target" \
     || die "Error building framework while copying AlfrescoSDK universal library"

  # Current directory matters to ln.
  cd "$framework_path"
  ln -s ./Versions/A/Headers ./Headers
  ln -s ./Versions/A/Resources ./Resources
  ln -s ./Versions/A/$framework_target ./$framework_target
  cd "$framework_path/Versions"
  ln -s ./A ./Current
}

build_framework "$ALFRESCO_IOS_SDK_PRODUCT_NAME" \
                "$ALFRESCO_IOS_SDK_UNIVERSAL_LIBRARY" \
                "$ALFRESCO_IOS_SDK_FRAMEWORK_NAME" \
                "$ALFRESCO_IOS_SDK_FRAMEWORK"

build_framework "$ALFRESCO_OSX_SDK_PRODUCT_NAME" \
                "$ALFRESCO_OSX_SDK_UNIVERSAL_LIBRARY" \
                "$ALFRESCO_OSX_SDK_FRAMEWORK_NAME" \
                "$ALFRESCO_OSX_SDK_FRAMEWORK"

cd "$ALFRESCO_SDK_ROOT"

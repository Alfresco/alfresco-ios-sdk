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
# Package destination directory
#
test -d $ALFRESCO_SDK_PACKAGE \
   || mkdir -p $ALFRESCO_SDK_PACKAGE \
   || die "Could not create directory $ALFRESCO_SDK_PACKAGE"


# -----------------------------------------------------------------------------
# Script Parameters
#
usage () {
   echo 
   echo "usage: $(basename $0) [--no-docs] [Release|Debug]"
   echo "  --no-docs : Prevent appledoc generation"
   echo "  Release|Debug: Specify build configuration. Defaults to Release if not set"
   echo
   exit 1
}

# Script Defaults
GENERATE_DOCS="true"

for param in $*
do
   if [[ "$param" == "--no-docs" ]] ; then
      GENERATE_DOCS=""
   elif [[ "$param" == "--help" ]] ; then
      usage #exits
   fi
done


# -----------------------------------------------------------------------------
# Package static libraries and frameworks
#

# Build static libraries and frameworks
. $ALFRESCO_SDK_SCRIPT/build_framework.sh $BUILD_CONFIGURATION \
   || die "AlfrescoSDK framework(s) failed to build."


# -----------------------------------------------------------------------------
# Function parameters
#    package zip - path to destination (package) zip file
#    library and include path - e.g. /Users/[username]/alfresco-ios-sdk/build/Release-universal
#
function build_library_package() {
   # local variables
   local package_zip=${1}
   local library_path=${2}

   # Package static library - text files, universal library, header files
   progress_message "Packaging static library to $ALFRESCO_IOS_SDK_LIBRARY_ZIP"

   # Test the package_zip is a subfolder of the main build path
   if [[ $package_zip =~ $ALFRESCO_SDK_BUILD ]]; then
     \rm -rf "$package_zip"
   else
     die "Location of zip file is not a subfolder of $ALFRESCO_SDK_ROOT ($package_zip)"
   fi

   pushd $ALFRESCO_SDK_ROOT
   zip $package_zip README LICENSE NOTICE
   popd
   pushd $library_path
   zip -r $package_zip *
   popd
}

# -----------------------------------------------------------------------------
# Function parameters
#    package zip - path to destination (package) zip file
#    framework build path - e.g. /Users/[username]/alfresco-ios-sdk/build/AlfrescoSDK-iOS.framework
#
function build_framework_package() {
   # local variables
   local package_zip=${1}
   local framework_path=${2}

   # Package framework - text files, framework structure
   progress_message "Packaging framework to $package_zip"

   # Test the package_zip is a subfolder of the main build path
   if [[ $package_zip =~ $ALFRESCO_SDK_BUILD ]]; then
     \rm -rf "$package_zip"
   else
     die "Location of zip file is not a subfolder of $ALFRESCO_SDK_ROOT ($package_zip)"
   fi

   pushd $ALFRESCO_SDK_ROOT
   zip $package_zip README LICENSE NOTICE
   popd
   pushd $(dirname $framework_path)
   zip -gry $package_zip $(basename $framework_path)
   popd
}

# iOS
build_library_package "$ALFRESCO_IOS_SDK_LIBRARY_ZIP" \
                      "$ALFRESCO_IOS_SDK_UNIVERSAL_LIBRARY_PATH"

build_framework_package "$ALFRESCO_IOS_SDK_FRAMEWORK_ZIP" \
                        "$ALFRESCO_IOS_SDK_FRAMEWORK"

# Mac OS X
build_library_package "$ALFRESCO_OSX_SDK_LIBRARY_ZIP" \
                      "$ALFRESCO_OSX_SDK_LIBRARY_PATH"

build_framework_package "$ALFRESCO_OSX_SDK_FRAMEWORK_ZIP" \
                        "$ALFRESCO_OSX_SDK_FRAMEWORK"


# -----------------------------------------------------------------------------
# Generate documentation
#

if [[ "$GENERATE_DOCS" == "true" ]] ; then
   progress_message "Packaging help to $ALFRESCO_SDK_DOCSET_ZIP"

   # Build documentation
   . $ALFRESCO_SDK_SCRIPT/build_appledoc.sh \
      || die "Documentation failed to build."

   # Package documentation

   # Test the ALFRESCO_SDK_DOCSET_ZIP is a subfolder of the main build path
   if [[ $ALFRESCO_SDK_DOCSET_ZIP =~ $ALFRESCO_SDK_BUILD ]]; then
     \rm -rf "$ALFRESCO_SDK_DOCSET_ZIP"
   else
     die "ALFRESCO_SDK_DOCSET_ZIP is not a subfolder of $ALFRESCO_SDK_ROOT ($ALFRESCO_SDK_DOCSET_ZIP)"
   fi

   pushd $ALFRESCO_SDK_BUILD
   zip -r $ALFRESCO_SDK_DOCSET_ZIP $ALFRESCO_SDK_DOCSET_NAME
   popd

fi

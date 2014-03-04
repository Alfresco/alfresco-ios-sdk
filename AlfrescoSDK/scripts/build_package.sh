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

# Package dir
ALFRESCO_SDK_PACKAGE=$ALFRESCO_SDK_BUILD/Package

test -d $ALFRESCO_SDK_PACKAGE \
   || mkdir -p $ALFRESCO_SDK_PACKAGE \
   || die "Could not create directory $ALFRESCO_SDK_PACKAGE"


# -----------------------------------------------------------------------------
# Script Parameters
#
underline=`tput smul`
nounderline=`tput rmul`
bold=`tput bold`
normal=`tput sgr0`

usage () {
   echo 
   echo "usage: $(basename $0) [${bold}--no-docs${normal}] ${underline}build configuration${nounderline}"
   echo "  --no-docs : Prevent appledoc generation"
   echo "  build configuration : Specify Debug or Release. Note: defaults to Release"
   echo
   exit 1
}

# Script Defaults
BUILD_CONFIGURATION=Release
LIBRARY_SUFFIX=""
GENERATE_DOCS="true"

for param in $*
do
   if [[ "$param" == "Debug" ]] ; then
      BUILD_CONFIGURATION=Debug
      LIBRARY_SUFFIX="-debug"
   elif [[ "$param" == "--no-docs" ]] ; then
      GENERATE_DOCS=""
   elif [[ "$param" == "--help" ]] ; then
      usage
   fi
done


# -----------------------------------------------------------------------------
# Build AlfrescoSDK.framework
#
ALFRESCO_SDK_FRAMEWORK_ZIP_NAME=alfresco-ios-sdk-$ALFRESCO_SDK_VERSION"$LIBRARY_SUFFIX".zip
ALFRESCO_SDK_FRAMEWORK_ZIP=$ALFRESCO_SDK_PACKAGE/$ALFRESCO_SDK_FRAMEWORK_ZIP_NAME

progress_message "Packaging framework to $ALFRESCO_SDK_FRAMEWORK_ZIP - $BUILD_CONFIGURATION configuration"

# Build framework
. $ALFRESCO_SDK_SCRIPT/build_framework.sh $BUILD_CONFIGURATION \
   || die "AlfrescoSDK.framework failed to build."

# Package framework
\rm -rf $ALFRESCO_SDK_FRAMEWORK_ZIP
pushd $ALFRESCO_SDK_ROOT
zip $ALFRESCO_SDK_FRAMEWORK_ZIP README LICENSE NOTICE
popd
pushd $ALFRESCO_SDK_BUILD
zip -gry $ALFRESCO_SDK_FRAMEWORK_ZIP $ALFRESCO_SDK_FRAMEWORK
popd


# -----------------------------------------------------------------------------
# Generate documentation
#
ALFRESCO_SDK_DOCSET_ZIP_NAME=alfresco-ios-sdk-docset-$ALFRESCO_SDK_VERSION.zip
ALFRESCO_SDK_DOCSET_ZIP=$ALFRESCO_SDK_PACKAGE/$ALFRESCO_SDK_DOCSET_ZIP_NAME

if [[ "$GENERATE_DOCS" == "true" ]] ; then
   progress_message "Packaging help to $ALFRESCO_SDK_DOCSET_ZIP"

   # Build documentation
   . $ALFRESCO_SDK_SCRIPT/build_appledoc.sh \
      || die "Documentation failed to build."

   # Package documentation
   \rm -rf $ALFRESCO_SDK_DOCSET_ZIP
   pushd $ALFRESCO_SDK_DOCSET_BUILD
   zip -r $ALFRESCO_SDK_DOCSET_ZIP $ALFRESCO_SDK_DOCSET_NAME
   popd

fi

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
. $ALFRESCO_SDK_SCRIPT/build_library.sh $BUILD_CONFIGURATION \
   || die "Static library failed to build."


# -----------------------------------------------------------------------------
# Build .framework folder structure
#
progress_message "Building $ALFRESCO_SDK_FRAMEWORK_NAME"

\rm -rf $ALFRESCO_SDK_FRAMEWORK
mkdir $ALFRESCO_SDK_FRAMEWORK \
   || die "Could not create directory $ALFRESCO_SDK_FRAMEWORK"
mkdir $ALFRESCO_SDK_FRAMEWORK/Versions
mkdir $ALFRESCO_SDK_FRAMEWORK/Versions/A
mkdir $ALFRESCO_SDK_FRAMEWORK/Versions/A/Headers
mkdir $ALFRESCO_SDK_FRAMEWORK/Versions/A/Resources

\cp \
   $ALFRESCO_SDK_SRC/Framework/Resources/* \
   $ALFRESCO_SDK_FRAMEWORK/Versions/A/Resources \
   || die "Error building framework while copying Resources"
\cp \
   $ALFRESCO_SDK_BUILD/$BUILD_CONFIGURATION-iphoneos/include/$ALFRESCO_SDK_PRODUCT_NAME/*.h \
   $ALFRESCO_SDK_FRAMEWORK/Versions/A/Headers \
   || die "Error building framework while copying SDK headers"
\cp \
   $ALFRESCO_SDK_UNIVERSAL_LIBRARY \
   $ALFRESCO_SDK_FRAMEWORK/Versions/A/$ALFRESCO_SDK_PRODUCT_NAME \
   || die "Error building framework while copying AlfrescoSDK universal library"

# Current directory matters to ln.
cd $ALFRESCO_SDK_FRAMEWORK
ln -s ./Versions/A/Headers ./Headers
ln -s ./Versions/A/Resources ./Resources
ln -s ./Versions/A/$ALFRESCO_SDK_PRODUCT_NAME ./$ALFRESCO_SDK_PRODUCT_NAME
cd $ALFRESCO_SDK_FRAMEWORK/Versions
ln -s ./A ./Current

cd $ALFRESCO_SDK_ROOT

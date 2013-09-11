#!/bin/bash

# Copyright (C) 2005-2013 Alfresco Software Limited.
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

source ./sdk_version.sh

ALFRESCO_SDK_HELP="AlfrescoSDKHelp"

# remove previous generated documentation
if [ -d $ALFRESCO_SDK_HELP ]; then
  rm -R $ALFRESCO_SDK_HELP
fi

# create directory
mkdir $ALFRESCO_SDK_HELP

# Build documentation if appledoc is installed
if type -p appledoc &>/dev/null; then
    appledoc \
    --project-name "AlfrescoSDK" \
    --project-company "Alfresco" \
    --company-id "com.alfresco" \
    --output "$ALFRESCO_SDK_HELP" \
    --exit-threshold 2 \
    --ignore ".m" \
    --ignore "AlfrescoSDKTests" \
    --ignore "CMIS" \
    --keep-intermediate-files \
    .
    cd $ALFRESCO_SDK_HELP
    mv docset com.alfresco.AlfrescoSDK.docset
    jar cvf alfresco-ios-sdk-docset-$ALFRESCO_SDK_VERSION.zip com.alfresco.AlfrescoSDK.docset
else
    echo "appledoc: executable can not be found, you can find installation instructions at https://github.com/tomaz/appledoc"
    echo "appledoc: Quick install via Homebrew: brew install appledoc"
fi

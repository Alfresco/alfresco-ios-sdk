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

. "${ALFRESCO_SDK_SCRIPT:-$(dirname "$0")}"/common.sh

test -x "$APPLEDOC" || die "Could not find appledoc in $PATH. Use \"brew install appledoc\""

test -d "$ALFRESCO_SDK_BUILD" \
   || mkdir -p "$ALFRESCO_SDK_BUILD" \
   || die "Could not create directory $ALFRESCO_SDK_BUILD"

# -----------------------------------------------------------------------------
# Build documentation
#
cd "$ALFRESCO_SDK_ROOT"

# Test the ALFRESCO_SDK_DOCSET_BUILD is a subfolder of the main build path
if [[ $ALFRESCO_SDK_DOCSET_BUILD =~ $ALFRESCO_SDK_BUILD ]]; then
  \rm -rf "$ALFRESCO_SDK_DOCSET_BUILD"
else
  die "ALFRESCO_SDK_DOCSET_BUILD is not a subfolder of $ALFRESCO_SDK_ROOT ($ALFRESCO_SDK_DOCSET_BUILD)"
fi

mkdir "$ALFRESCO_SDK_DOCSET_BUILD" \
  || die "Could not create directory $ALFRESCO_SDK_DOCSET_BUILD"

$APPLEDOC \
   --project-name "$ALFRESCO_SDK_PRODUCT_NAME" \
   --project-company "Alfresco" \
   --company-id "com.alfresco" \
   --output "$ALFRESCO_SDK_DOCSET_BUILD" \
   --exit-threshold 2 \
   --ignore ".m" \
   --ignore "build" \
   --ignore "AlfrescoSDKTests" \
   --ignore "CMIS" \
   --keep-intermediate-files \
   --no-install-docset \
   . \
   || die "appledoc failed to build documentation"

cd "$ALFRESCO_SDK_DOCSET_BUILD"
mv docset "$ALFRESCO_SDK_DOCSET_NAME"

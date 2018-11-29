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

test -x "$JAZZY" || die "Could not find jazzy in $PATH. Use \"[sudo] gem install jazz\""

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

jazzy || die "jazzy failed to build documentation"

mv "$ALFRESCO_SDK_DOCSET_NAME" "$ALFRESCO_SDK_BUILD" \
    || die "Could not create directory $ALFRESCO_SDK_DOCSET_BUILD"
cd "$ALFRESCO_SDK_DOCSET_BUILD"

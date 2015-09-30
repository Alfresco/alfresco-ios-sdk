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
# Script Parameters
#
underline=`tput smul`
nounderline=`tput rmul`
bold=`tput bold`
normal=`tput sgr0`

usage ()
{
   echo 
   echo "usage: $(basename $0) [${bold}--junit${normal}] ${underline}test server${nounderline}"
   echo "  --junit : Pipe output through ocunit2junit to allow Bamboo to parse test results"
   echo "  test server : Test server key within ~/ios-sdk-test-config/test-servers.plist"
   echo
   exit 1
}

# remove previous test reports
if [[ -d test-reports ]] ; then
  progress_message "Removing previous test-reports folder..."
  rm -R test-reports
fi

# check there are parameters
if [[ "$1" == "" ]] ; then
   usage
else
   for param in $*
   do
      if [[ "$param" == "--junit" ]] ; then
         JUNIT_FLAG="true"
      else
         # define the main command
         BUILD_OPTS=(test -scheme $ALFRESCO_SDK_PRODUCT_NAME -destination OS=latest,name="iPhone 6s" TEST_SERVER=${param})
      fi
   done
fi

if [[ "$BUILD_OPTS" == "" ]] ; then
   usage
fi

if [[ "$JUNIT_FLAG" == "true" ]] ; then
   progress_message "Tests are running, output is being piped to ocunit2junit, results will appear soon..."
   $XCODEBUILD "${BUILD_OPTS[@]}" 2>&1 | ocunit2junit
else
   $XCODEBUILD "${BUILD_OPTS[@]}"
fi

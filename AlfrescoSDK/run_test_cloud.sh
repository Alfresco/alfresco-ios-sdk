#!/bin/bash

# remove previous test reports
if [ -d test-reports ]; then
  echo "Removing previous test-reports folder..."
  rm -R test-reports
fi

# define the main command
TEST_SERVER_PLIST=$HOME/test-servers-Cloud.plist
export TEST_SERVER_PLIST

BUILD_CMD="xcodebuild -sdk iphonesimulator -project AlfrescoSDK.xcodeproj -target AlfrescoSDKTests -configuration Debug TEST_AFTER_BUILD=YES clean build"

# determine whether to pipe the unit tests results or not
if [[ "$1" == "-output-junit-results" ]] ; then
   echo "Tests are running, output is being piped to ocunit2junit, results will appear soon..."
   $BUILD_CMD 2>&1 | ocunit2junit
else
   $BUILD_CMD
fi

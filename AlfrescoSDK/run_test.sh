#!/bin/bash

underline=`tput smul`
nounderline=`tput rmul`
bold=`tput bold`
normal=`tput sgr0`

usage ()
{
   echo 
   echo "usage: run_test [${bold}-junit${normal}] ${underline}test server${nounderline}"
   echo "  -junit : Pipe output through ocunit2junit to allow Bamboo to parse test results"
   echo "  test server : Test server key within ~/ios-sdk-test-config/test-servers.plist"
   echo
   exit 1
}

# remove previous test reports
if [[ -d test-reports ]] ; then
  echo "Removing previous test-reports folder..."
  rm -R test-reports
fi

# check there are parameters
if [[ "$1" == "" ]] ; then
   usage
else
   for param in $*
   do
      if [[ "$param" == "-junit" ]] ; then
         JUNIT_FLAG="true"
      else
         # define the main command
         BUILD_OPTS=(test -scheme AlfrescoSDK -destination OS=7.0,name="iPhone Retina (4-inch)" TEST_SERVER=${param})
      fi
   done
fi

if [[ "$BUILD_OPTS" == "" ]] ; then
   usage
fi

if [[ "$JUNIT_FLAG" == "true" ]] ; then
   echo "Tests are running, output is being piped to ocunit2junit, results will appear soon..."
   xcodebuild "${BUILD_OPTS[@]}" 2>&1 | ocunit2junit
else
   xcodebuild "${BUILD_OPTS[@]}"
fi

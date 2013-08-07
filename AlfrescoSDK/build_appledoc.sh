#!/bin/bash

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
    jar cvf alfresco-ios-sdk-docset-1.1.0.zip com.alfresco.AlfrescoSDK.docset
else
    echo "appledoc: executable can not be found, you can find installation instructions at https://github.com/tomaz/appledoc"
    echo "appledoc: Quick install via Homebrew: brew install appledoc"
fi

#!/bin/bash

# remove previous generated documentation
if [ -d AlfrescoSDKHelp ]; then
  rm -R AlfrescoSDKHelp
fi

# create directory
mkdir AlfrescoSDKHelp

# Build documentation if appledoc is installed
if type -p appledoc &>/dev/null; then
    appledoc --project-name AlfrescoSDK --project-company "Alfresco" --company-id com.alfresco --output AlfrescoSDKHelp --keep-intermediate-files --exit-threshold 2 --ignore .m --ignore AlfrescoSDKTests . --ignore CMIS .
else
    echo "appledoc executable can not be found, you can find installation instuctions at https://github.com/tomaz/appledoc"
fi

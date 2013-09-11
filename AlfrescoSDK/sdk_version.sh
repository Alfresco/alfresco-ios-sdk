#!/bin/bash

#
# Extracts the Alfresco SDK Version from the project's xcconfig file.
#
ALFRESCO_SDK_VERSION=`sed -ne '/^ALFRESCO_SDK_VERSION=/s/.*=\([\^]*\)/\1/p' AlfrescoSDK/AlfrescoSDK.xcconfig`
echo Alfresco SDK Version detected: $ALFRESCO_SDK_VERSION
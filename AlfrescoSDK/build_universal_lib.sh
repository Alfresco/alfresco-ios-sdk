BUILD_UNIVERSAL_LIB='TRUE'
export BUILD_UNIVERSAL_LIB
xcodebuild -project AlfrescoSDK.xcodeproj -target AlfrescoSDK -configuration Debug clean build

# Build documentation if appledoc is installed
if type -p appledoc &>/dev/null; then
    appledoc --project-name AlfrescoSDK --project-company "Alfresco" --company-id com.alfresco.alfrescosdk --output ./AlfrescoSDK/help --keep-intermediate-files --exit-threshold 2 --ignore .m --ignore AlfrescoSDKTests . --ignore CMIS .
fi
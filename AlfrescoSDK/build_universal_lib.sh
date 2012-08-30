BUILD_UNIVERSAL_LIB='TRUE'
export BUILD_UNIVERSAL_LIB
xcodebuild -project AlfrescoSDK.xcodeproj -target AlfrescoSDK -configuration Debug clean build

appledoc --project-name AlfrescoSDK --project-company "Alfresco" --company-id com.alfresco.alfrescosdk --output ./AlfrescoSDK/help --keep-intermediate-files --exit-threshold 2 --keep-undocumented-objects --keep-undocumented-members --ignore .m --ignore AlfrescoSDKTests .


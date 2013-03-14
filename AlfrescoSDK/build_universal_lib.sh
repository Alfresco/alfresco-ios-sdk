BUILD_UNIVERSAL_LIB='TRUE'
export BUILD_UNIVERSAL_LIB
xcodebuild -project AlfrescoSDK.xcodeproj -target AlfrescoSDK -configuration Debug clean build

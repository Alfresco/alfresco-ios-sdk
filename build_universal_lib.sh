BUILD_UNIVERSAL_LIB='TRUE'
export BUILD_UNIVERSAL_LIB
xcodebuild -project ObjectiveCMIS.xcodeproj -target ObjectiveCMIS -configuration Release clean build

appledoc --project-name ObjectiveCMIS --project-company "Apache Chemistry" --company-id org.apache.chemistry.opencmis --output ./ObjectiveCMISHelp --keep-intermediate-files --exit-threshold 2 --keep-undocumented-objects --keep-undocumented-members --ignore .m --ignore ObjectiveCMISTests .


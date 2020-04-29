/*******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Mobile SDK.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ******************************************************************************/

#import "AlfrescoUtilsTest.h"
#import "AlfrescoConstants.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoListingContext.h"
#import "AlfrescoActivityStreamService.h"
#import "AlfrescoCommentService.h"
#import "AlfrescoDocumentFolderService.h"
#import "AlfrescoModelDefinitionService.h"
#import "AlfrescoPersonService.h"
#import "AlfrescoRatingService.h"
#import "AlfrescoSearchService.h"
#import "AlfrescoSiteService.h"
#import "AlfrescoTaggingService.h"
#import "AlfrescoVersionService.h"
#import "AlfrescoWorkflowService.h"
#import "AlfrescoObjectConverter.h"
#import "AlfrescoVersionInfo.h"
#import "AlfrescoFileManager.h"
#import "AlfrescoWorkflowObjectConverter.h"

@implementation AlfrescoUtilsTest

- (void)testListingContext
{
    // test defaults are as expected
    AlfrescoListingContext *listingContext = [AlfrescoListingContext new];
    XCTAssertTrue(listingContext.maxItems == 50, @"Expected maxItems to default to 50");
    XCTAssertTrue(listingContext.skipCount == 0, @"Expected skipCount to default to 0");
    XCTAssertTrue(listingContext.sortAscending, @"Expected sortAscending to default to YES");
    XCTAssertNil(listingContext.sortProperty, @"Expected sortProperty to default to nil");
    XCTAssertNotNil(listingContext.listingFilter, @"Expected to find a default listingFilter");
    XCTAssertTrue(listingContext.listingFilter.filters.count == 0,
                  "Expected the default listingFilter to be empty but it had %lu filters", (unsigned long)listingContext.listingFilter.filters.count);
    
    // test various initialisers work correctly
    listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:20];
    XCTAssertTrue(listingContext.maxItems == 20, @"Expected maxItems to be 20 but it was %d", listingContext.maxItems);
    XCTAssertTrue(listingContext.skipCount == 0, @"Expected skipCount to default to 0");
    
    listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:25 skipCount:100];
    XCTAssertTrue(listingContext.maxItems == 25, @"Expected maxItems to be 25 but it was %d", listingContext.maxItems);
    XCTAssertTrue(listingContext.skipCount == 100, @"Expected skipCount to be 100 but it was %d", listingContext.skipCount);
    
    listingContext = [[AlfrescoListingContext alloc] initWithSortProperty:kAlfrescoSortByTitle sortAscending:NO];
    XCTAssertTrue(listingContext.maxItems == 50, @"Expected maxItems to default to 50");
    XCTAssertTrue(listingContext.skipCount == 0, @"Expected skipCount to default to 0");
    XCTAssertTrue([listingContext.sortProperty isEqualToString:kAlfrescoSortByTitle],
                  @"Expected sortProperty to be %@ but it was %@", kAlfrescoSortByTitle, listingContext.sortProperty);
    XCTAssertFalse(listingContext.sortAscending, @"Expected sortAscending to be NO");
    
    AlfrescoListingFilter *listingFilter = [[AlfrescoListingFilter alloc] initWithFilter:kAlfrescoFilterByWorkflowStatus value:kAlfrescoFilterValueWorkflowStatusActive];
    listingContext = [[AlfrescoListingContext alloc] initWithListingFilter:listingFilter];
    XCTAssertTrue(listingContext.maxItems == 50, @"Expected maxItems to default to 50");
    XCTAssertTrue(listingContext.skipCount == 0, @"Expected skipCount to default to 0");
    XCTAssertEqual(listingFilter, listingContext.listingFilter, @"Expected the given listing filter to be the one returned from the listing context");
    XCTAssertTrue(listingContext.listingFilter.filters.count == 1,
                  "Expected listingFilter to have 1 filter but it had %lu", (unsigned long)listingContext.listingFilter.filters.count);
    XCTAssertTrue([listingContext.listingFilter hasFilter:kAlfrescoFilterByWorkflowStatus], @"Expected the listing filter to have the kAlfrescoFilterByWorkflowStatus filter");
    XCTAssertTrue([[listingContext.listingFilter valueForFilter:kAlfrescoFilterByWorkflowStatus] isEqualToString:kAlfrescoFilterValueWorkflowStatusActive],
                  @"Expected the listing filter value to be kAlfrescoFilterValueWorkflowStateActive but it was %@", [listingContext.listingFilter valueForFilter:kAlfrescoFilterByWorkflowStatus]);
    
    // test the properties are readwrite
    listingContext = [AlfrescoListingContext new];
    listingContext.maxItems = 100;
    listingContext.skipCount = 100;
    listingContext.sortAscending = NO;
    listingContext.sortProperty = kAlfrescoSortByDescription;
    listingContext.listingFilter = listingFilter;
}

- (void)testServiceCreationWithNilSession
{
    AlfrescoActivityStreamService *streamService = [[AlfrescoActivityStreamService alloc] initWithSession:nil];
    XCTAssertNil(streamService, @"Expected streamService to be nil as it was created with a nil session");
    
    AlfrescoCommentService *commentService = [[AlfrescoCommentService alloc] initWithSession:nil];
    XCTAssertNil(commentService, @"Expected commentService to be nil as it was created with a nil session");
        
    AlfrescoDocumentFolderService *docFolderService = [[AlfrescoDocumentFolderService alloc] initWithSession:nil];
    XCTAssertNil(docFolderService, @"Expected docFolderService to be nil as it was created with a nil session");
    
    AlfrescoModelDefinitionService *modelDefinitionService = [[AlfrescoModelDefinitionService alloc] initWithSession:nil];
    XCTAssertNil(modelDefinitionService, @"Expected modelDefinitionService to be nil as it was created with a nil session");
    
    AlfrescoPersonService *personService = [[AlfrescoPersonService alloc] initWithSession:nil];
    XCTAssertNil(personService, @"Expected personService to be nil as it was created with a nil session");
    
    AlfrescoRatingService *ratingService = [[AlfrescoRatingService alloc] initWithSession:nil];
    XCTAssertNil(ratingService, @"Expected ratingService to be nil as it was created with a nil session");
    
    AlfrescoSearchService *searchService = [[AlfrescoSearchService alloc] initWithSession:nil];
    XCTAssertNil(searchService, @"Expected searchService to be nil as it was created with a nil session");
    
    AlfrescoSiteService *siteService = [[AlfrescoSiteService alloc] initWithSession:nil];
    XCTAssertNil(siteService, @"Expected siteService to be nil as it was created with a nil session");
    
    AlfrescoTaggingService *taggingService = [[AlfrescoTaggingService alloc] initWithSession:nil];
    XCTAssertNil(taggingService, @"Expected taggingService to be nil as it was created with a nil session");
    
    AlfrescoVersionService *versionService = [[AlfrescoVersionService alloc] initWithSession:nil];
    XCTAssertNil(versionService, @"Expected versionService to be nil as it was created with a nil session");
    
    AlfrescoWorkflowService *workflowService = [[AlfrescoWorkflowService alloc] initWithSession:nil];
    XCTAssertNil(workflowService, @"Expected workflowService to be nil as it was created with a nil session");
}

- (void)testMappingDictionaryKeys
{
    NSDictionary *sourceDictionary = @{@"id": @"123", @"label-id": @"an-nls-id", @"description": @"The description"};
    
    NSDictionary *targetDictionary = [AlfrescoObjectConverter dictionaryFromDictionary:sourceDictionary
                                                                        withMappedKeys:@{@"id": @"identifier",
                                                                                         @"label-id": @"label",
                                                                                         @"description": @"summary"}];
    
    // make sure new keys are present
    XCTAssertNotNil(targetDictionary[@"identifier"], @"Expected to find key 'identifier'");
    XCTAssertNotNil(targetDictionary[@"label"], @"Expected to find key 'label'");
    XCTAssertNotNil(targetDictionary[@"summary"], @"Expected to find key 'summary'");
    
    // make sure old keys are removed
    XCTAssertNil(targetDictionary[@"id"], @"Did not expect to find key 'id'");
    XCTAssertNil(targetDictionary[@"label-id"], @"Did not expect to find key 'label-id'");
    XCTAssertNil(targetDictionary[@"description"], @"Did not expect to find key 'description'");
    
    // make sure values are still correct
    NSString *identifier = targetDictionary[@"identifier"];
    XCTAssertTrue([identifier isEqualToString:@"123"], @"Expected value of 'identifier' to be '123' but it was %@", identifier);
    NSString *label = targetDictionary[@"label"];
    XCTAssertTrue([label isEqualToString:@"an-nls-id"], @"Expected value of 'label' to be 'an-nls-id' but it was %@", label);
    NSString *summary = targetDictionary[@"summary"];
    XCTAssertTrue([summary isEqualToString:@"The description"], @"Expected value of 'summary' to be 'The description' but it was %@", summary);
    
    // test non-existent keys and Null
    sourceDictionary = @{@"id": @"123", @"null": [NSNull new]};
    targetDictionary = [AlfrescoObjectConverter dictionaryFromDictionary:sourceDictionary
                                                          withMappedKeys:@{@"id": @"identifier",
                                                                           @"default": @"isDefault",
                                                                           @"null": @"nullObject"}];
    XCTAssertTrue(targetDictionary.count == 2, @"Expected the dictionary to have 2 entries but it has %lu", (long)targetDictionary.count);
    XCTAssertNotNil(targetDictionary[@"identifier"], @"Expected to find key 'identifier'");
    XCTAssertNil(targetDictionary[@"default"], @"Did not expect to find key 'default'");
    XCTAssertNil(targetDictionary[@"isDefault"], @"Did not expect to find key 'isDefault'");
    XCTAssertNotNil(targetDictionary[@"nullObject"], @"Expected to find key 'nullObject'");
    XCTAssertNil(targetDictionary[@"null"], @"Did not expect to find key 'null'");
    XCTAssertTrue([targetDictionary[@"nullObject"] isKindOfClass:[NSNull class]],
                  @"Expected 'nullObject' to be an NSNull class but it was %@", targetDictionary[@"nullObject"]);
    
    // test protection against removing existing items i.e. if the existing and mapped key are the same
    sourceDictionary = @{@"id": @"123"};
    targetDictionary = [AlfrescoObjectConverter dictionaryFromDictionary:sourceDictionary
                                                          withMappedKeys:@{@"id": @"id"}];
    XCTAssertTrue(targetDictionary.count == 1, @"Expected the target dictionary to have 1 item still but it had %lu", (long)targetDictionary.count);
    XCTAssertTrue([targetDictionary[@"id"] isEqualToString:@"123"], @"Expected target dictionary to still have the 'id' key");
}

- (void)testVersionInfo
{
    AlfrescoVersionInfo *test1 = [[AlfrescoVersionInfo alloc] initWithVersionString:@"3.4.10 (703)"
                                                                            edition:kAlfrescoRepositoryEditionEnterprise];
    XCTAssertTrue([test1.majorVersion intValue] == 3,
                  @"Expected major version to be 3 but it was %@", test1.majorVersion);
    XCTAssertTrue([test1.minorVersion intValue] == 4,
                  @"Expected minor version to be 4 but it was %@", test1.minorVersion);
    XCTAssertTrue([test1.maintenanceVersion intValue] == 10,
                  @"Expected maintenance version to be 10 but it was %@", test1.maintenanceVersion);
    XCTAssertTrue([test1.buildNumber isEqualToString:@"703"],
                  @"Expected build number to be 703 but it was %@", test1.buildNumber);
    
    AlfrescoVersionInfo *test2 = [[AlfrescoVersionInfo alloc] initWithVersionString:@"4.0.2 (966)"
                                                                            edition:kAlfrescoRepositoryEditionEnterprise];
    XCTAssertTrue([test2.majorVersion intValue] == 4,
                  @"Expected major version to be 4 but it was %@", test2.majorVersion);
    XCTAssertTrue([test2.minorVersion intValue] == 0,
                  @"Expected minor version to be 0 but it was %@", test2.minorVersion);
    XCTAssertTrue([test2.maintenanceVersion intValue] == 2,
                  @"Expected maintenance version to be 2 but it was %@", test2.maintenanceVersion);
    XCTAssertTrue([test2.buildNumber isEqualToString:@"966"],
                  @"Expected build number to be 966 but it was %@", test2.buildNumber);
    
    AlfrescoVersionInfo *test3 = [[AlfrescoVersionInfo alloc] initWithVersionString:@"4.2.0 (.3 r60922-b49)"
                                                                            edition:kAlfrescoRepositoryEditionEnterprise];
    XCTAssertTrue([test3.majorVersion intValue] == 4,
                  @"Expected major version to be 4 but it was %@", test3.majorVersion);
    XCTAssertTrue([test3.minorVersion intValue] == 2,
                  @"Expected minor version to be 2 but it was %@", test3.minorVersion);
    XCTAssertTrue([test3.maintenanceVersion intValue] == 0,
                  @"Expected maintenance version to be 0 but it was %@", test3.maintenanceVersion);
    XCTAssertTrue([test3.buildNumber isEqualToString:@".3 r60922-b49"],
                  @"Expected build number to be '.3 r60922-b49' but it was %@", test3.buildNumber);
    
    AlfrescoVersionInfo *test4 = [[AlfrescoVersionInfo alloc] initWithVersionString:@"4.2.0 (@build-number@)"
                                                                            edition:kAlfrescoRepositoryEditionCommunity];
    XCTAssertTrue([test4.majorVersion intValue] == 4,
                  @"Expected major version to be 4 but it was %@", test4.majorVersion);
    XCTAssertTrue([test4.minorVersion intValue] == 2,
                  @"Expected minor version to be 2 but it was %@", test4.minorVersion);
    XCTAssertTrue([test4.maintenanceVersion intValue] == 0,
                  @"Expected maintenance version to be 0 but it was %@", test4.maintenanceVersion);
    XCTAssertTrue([test4.buildNumber isEqualToString:@"@build-number@"],
                  @"Expected build number to be '@build-number@' but it was %@", test4.buildNumber);
    
    AlfrescoVersionInfo *test5 = [[AlfrescoVersionInfo alloc] initWithVersionString:@"4.1.0"
                                                                            edition:kAlfrescoRepositoryEditionEnterprise];
    XCTAssertTrue([test5.majorVersion intValue] == 4,
                  @"Expected major version to be 4 but it was %@", test5.majorVersion);
    XCTAssertTrue([test5.minorVersion intValue] == 1,
                  @"Expected minor version to be 1 but it was %@", test5.minorVersion);
    XCTAssertTrue([test5.maintenanceVersion intValue] == 0,
                  @"Expected maintenance version to be 0 but it was %@", test5.maintenanceVersion);
    XCTAssertNil(test5.buildNumber, @"Expected build number to be nil but it was %@", test5.buildNumber);
    
    AlfrescoVersionInfo *test6 = [[AlfrescoVersionInfo alloc] initWithVersionString:@"4.1"
                                                                            edition:kAlfrescoRepositoryEditionEnterprise];
    XCTAssertTrue([test6.majorVersion intValue] == 4,
                  @"Expected major version to be 4 but it was %@", test6.majorVersion);
    XCTAssertTrue([test6.minorVersion intValue] == 1,
                  @"Expected minor version to be 1 but it was %@", test6.minorVersion);
    XCTAssertNotNil(test6.maintenanceVersion);
    XCTAssertTrue([test6.maintenanceVersion intValue] == 0,
                  @"Expected maintenance version to be 0 but it was %@", test6.maintenanceVersion);
    XCTAssertNil(test6.buildNumber, @"Expected build number to be nil but it was %@", test6.buildNumber);
    
    AlfrescoVersionInfo *test7 = [[AlfrescoVersionInfo alloc] initWithVersionString:@"5"
                                                                            edition:kAlfrescoRepositoryEditionCommunity];
    XCTAssertTrue([test7.majorVersion intValue] == 5,
                  @"Expected major version to be 5 but it was %@", test7.majorVersion);
    XCTAssertNotNil(test7.minorVersion);
    XCTAssertTrue([test7.minorVersion intValue] == 0,
                  @"Expected minor version to be 0 but it was %@", test7.minorVersion);
    XCTAssertNotNil(test7.maintenanceVersion);
    XCTAssertTrue([test7.maintenanceVersion intValue] == 0,
                  @"Expected maintenance version to be 0 but it was %@", test7.maintenanceVersion);
    XCTAssertNil(test7.buildNumber, @"Expected build number to be nil but it was %@", test7.buildNumber);
}

- (void)testFileManager
{
    AlfrescoFileManager *fileManager = [AlfrescoFileManager sharedManager];
    // create a temporary file with some contents
    NSString *contents = @"This is the original content";
    NSString *tempPath = [fileManager.temporaryDirectory stringByAppendingString:[[NSUUID UUID] UUIDString]];
    
    NSError *error = nil;
    [fileManager createFileAtPath:tempPath contents:[contents dataUsingEncoding:NSUTF8StringEncoding] error:&error];
    XCTAssertNil(error, @"Expected the temp file to be created successfully");

    // replace the file created above with some new content
    NSString *replacementContent = @"This is the replacement content";
    [fileManager replaceFileAtURL:[NSURL fileURLWithPath:tempPath] contents:[replacementContent dataUsingEncoding:NSUTF8StringEncoding] error:&error];
    XCTAssertNil(error, @"Expected the temp file to be replaced successfully");
    XCTAssertTrue([fileManager fileExistsAtPath:tempPath], @"Expected the temp file to still exist");
    
    // ensure the content was replaced
    NSData *retrievedContent = [fileManager dataWithContentsOfURL:[NSURL fileURLWithPath:tempPath]];
    NSString *retrievedContentString = [[NSString alloc] initWithData:retrievedContent encoding:NSUTF8StringEncoding];
    XCTAssertTrue([retrievedContentString isEqualToString:replacementContent],
                  @"Expected the content to match but it was: %@", retrievedContentString);
    
    // copy the file to another temporary file
    NSString *copiedTempPath = [fileManager.temporaryDirectory stringByAppendingString:[[NSUUID UUID] UUIDString]];
    [fileManager copyItemAtPath:tempPath toPath:copiedTempPath error:&error];
    XCTAssertNil(error, @"Expected the temp file to be copied successfully");
    XCTAssertTrue([fileManager fileExistsAtPath:copiedTempPath], @"Expected the copied file to exist");
    NSData *copiedContent = [fileManager dataWithContentsOfURL:[NSURL fileURLWithPath:copiedTempPath]];
    NSString *copiedContentString = [[NSString alloc] initWithData:copiedContent encoding:NSUTF8StringEncoding];
    XCTAssertTrue([copiedContentString isEqualToString:replacementContent],
                  @"Expected the copied content to match but it was: %@", retrievedContentString);
    
    // remove the temp files
    [fileManager removeItemAtPath:tempPath error:&error];
    XCTAssertNil(error, @"Expected the temp file to be deleted successfully");
    XCTAssertFalse([fileManager fileExistsAtPath:tempPath], @"Did not expect to find the temp file");
    
    [fileManager removeItemAtURL:[NSURL fileURLWithPath:copiedTempPath] error:&error];
    XCTAssertNil(error, @"Expected the copied file to be deleted successfully");
    XCTAssertFalse([fileManager fileExistsAtPath:copiedTempPath], @"Did not expect to find the copied file");
}

- (void)testWorkflowVariableDecoding
{
    NSString *decodedVariableName = [AlfrescoWorkflowObjectConverter decodeVariableName:nil];
    XCTAssertNil(decodedVariableName, @"Expected the decoded variable name to be nil");
    
    NSString *rawVariableName = kAlfrescoWorkflowVariableTaskTransition;
    decodedVariableName = [AlfrescoWorkflowObjectConverter decodeVariableName:rawVariableName];
    XCTAssertTrue([decodedVariableName isEqualToString:kAlfrescoWorkflowVariableTaskTransition],
                  @"Expected decoded variable name to be '%@' but it was: %@", kAlfrescoWorkflowVariableTaskTransition, decodedVariableName);
    
    rawVariableName = @"_startTaskId";
    decodedVariableName = [AlfrescoWorkflowObjectConverter decodeVariableName:rawVariableName];
    XCTAssertTrue([decodedVariableName isEqualToString:rawVariableName],
                  @"Expected decoded variable name to be '%@' but it was: %@", rawVariableName, decodedVariableName);
    
    rawVariableName = @"bpm_status";
    decodedVariableName = [AlfrescoWorkflowObjectConverter decodeVariableName:rawVariableName];
    XCTAssertTrue([decodedVariableName isEqualToString:kAlfrescoWorkflowVariableTaskStatus],
                  @"Expected decoded variable name to be '%@' but it was: %@", kAlfrescoWorkflowVariableTaskStatus, decodedVariableName);
    
    rawVariableName = @"custom_name_with_more_underscores";
    decodedVariableName = [AlfrescoWorkflowObjectConverter decodeVariableName:rawVariableName];
    XCTAssertTrue([decodedVariableName isEqualToString:@"custom:name_with_more_underscores"],
                  @"Expected decoded variable name to be 'custom:name_with_more_underscores' but it was: %@", decodedVariableName);
}

@end

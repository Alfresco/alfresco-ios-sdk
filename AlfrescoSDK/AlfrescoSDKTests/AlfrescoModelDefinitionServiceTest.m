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

#import "AlfrescoModelDefinitionServiceTest.h"
#import "AlfrescoErrors.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoWorkflowService.h"
#import "AlfrescoWorkflowTask.h"
#import "CMISConstants.h"

@implementation AlfrescoModelDefinitionServiceTest

- (void)testRetrieveDocumentTypeDefinition
{
    if (self.setUpSuccess)
    {
        self.modelDefinitionService = [[AlfrescoModelDefinitionService alloc] initWithSession:self.currentSession];
        
        // retrieve type definition for cm:content
        [self.modelDefinitionService retrieveDefinitionForDocumentType:@"cm:content" completionBlock:^(AlfrescoDocumentTypeDefinition *typeDefinition, NSError *error) {
            if (typeDefinition == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:error];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertTrue([typeDefinition.name isEqualToString:@"cm:content"],
                              @"Expected definition name to be 'cm:content' but it was %@", typeDefinition.name);
                XCTAssertTrue([typeDefinition.title isEqualToString:@"Document"],
                              @"Expected definition name to be 'Document' but it was %@", typeDefinition.title);
                XCTAssertTrue([typeDefinition.summary isEqualToString:@"Document Type"],
                              @"Expected definition name to be 'Document Type' but it was %@", typeDefinition.summary);
                XCTAssertNil(typeDefinition.parent, @"Expected parent to be nil but it was %@", typeDefinition.parent);
                XCTAssertNotNil(typeDefinition.propertyNames, @"Expected propertyNames property to be populated");
                XCTAssertTrue(typeDefinition.propertyNames.count > 20,
                              @"Expected there to be more than 20 property names but there were %lu", (long)typeDefinition.propertyNames.count);
                
                if ([self.currentSession.repositoryInfo.majorVersion intValue] > 3)
                {
                    // NOTE: mandatory aspect data is not returned for 3.x servers
                    XCTAssertNotNil(typeDefinition.mandatoryAspects, @"Expected mandatoryAspects property to be populated");
                    XCTAssertTrue(typeDefinition.mandatoryAspects.count == 1,
                                  @"Expected there to be 1 mandatory aspect but there were %lu", (long)typeDefinition.mandatoryAspects.count);
                    XCTAssertTrue([typeDefinition.mandatoryAspects[0] isEqualToString:@"sys:localized"],
                                  @"Expected mandatory aspect entry to be sys:localized but it was %@", typeDefinition.mandatoryAspects[0]);
                }
                
                // check for a few property names
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cmis:name"], @"Expected the cmis:name property to be present");
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cmis:createdBy"], @"Expected the cmis:createdBy property to be present");
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cmis:creationDate"], @"Expected the cmis:creationDate property to be present");
                
                // retrieve and check some property definition objects
                AlfrescoPropertyDefinition *namePropertyDefiniton = [typeDefinition propertyDefinitionForPropertyWithName:@"cmis:name"];
                XCTAssertNotNil(namePropertyDefiniton, @"Expected to find a property definition for cmis:name");
                XCTAssertTrue([namePropertyDefiniton.name isEqualToString:@"cmis:name"],
                              @"Expected name to be 'cmis:name' but it was %@", namePropertyDefiniton.name);
                XCTAssertTrue([namePropertyDefiniton.title isEqualToString:@"Name"],
                              @"Expected title to be 'Name' but it was %@", namePropertyDefiniton.title);
                XCTAssertTrue([namePropertyDefiniton.summary isEqualToString:@"Name"],
                              @"Expected summary to be 'Name' but it was %@", namePropertyDefiniton.summary);
                XCTAssertTrue(namePropertyDefiniton.type == AlfrescoPropertyTypeString,
                              @"Expected type to be a string but it was %d", (int)namePropertyDefiniton.type);
                XCTAssertTrue(namePropertyDefiniton.isRequired, @"Expected isRequired to be true");
                XCTAssertFalse(namePropertyDefiniton.isReadOnly, @"Expected isReadOnly to be false");
                XCTAssertFalse(namePropertyDefiniton.isMultiValued, @"Expected isMultiValued to be false");
                XCTAssertNil(namePropertyDefiniton.defaultValue,
                             @"Expected default value to be nil but it was %@", namePropertyDefiniton.defaultValue);
                XCTAssertNil(namePropertyDefiniton.allowableValues,
                             @"Expected allowable values to be nil but it was %@", namePropertyDefiniton.allowableValues);
                
                AlfrescoPropertyDefinition *creationDatePropertyDefiniton = [typeDefinition propertyDefinitionForPropertyWithName:@"cmis:creationDate"];
                XCTAssertNotNil(creationDatePropertyDefiniton, @"Expected to find a property definition for cmis:creationDate");
                XCTAssertTrue([creationDatePropertyDefiniton.name isEqualToString:@"cmis:creationDate"],
                              @"Expected name to be 'cmis:creationDate' but it was %@", creationDatePropertyDefiniton.name);
                XCTAssertTrue([creationDatePropertyDefiniton.title isEqualToString:@"Creation Date"],
                              @"Expected title to be 'Creation Date' but it was %@", creationDatePropertyDefiniton.title);
                XCTAssertTrue([creationDatePropertyDefiniton.summary isEqualToString:@"The object creation date"],
                              @"Expected summary to be 'The object creation date' but it was %@", creationDatePropertyDefiniton.summary);
                XCTAssertTrue(creationDatePropertyDefiniton.type == AlfrescoPropertyTypeDateTime,
                              @"Expected type to be a date time but it was %d", (int)creationDatePropertyDefiniton.type);
                XCTAssertFalse(creationDatePropertyDefiniton.isRequired, @"Expected isRequired to be false");
                XCTAssertTrue(creationDatePropertyDefiniton.isReadOnly, @"Expected isReadOnly to be true");
                XCTAssertFalse(creationDatePropertyDefiniton.isMultiValued, @"Expected isMultiValued to be false");
                XCTAssertNil(creationDatePropertyDefiniton.defaultValue,
                             @"Expected default value to be nil but it was %@", creationDatePropertyDefiniton.defaultValue);
                XCTAssertNil(creationDatePropertyDefiniton.allowableValues,
                             @"Expected allowable values to be nil but it was %@", creationDatePropertyDefiniton.allowableValues);
                
                self.lastTestSuccessful = YES;
                self.callbackCompleted = YES;
            }
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrieveFolderTypeDefinition
{
    if (self.setUpSuccess)
    {
        self.modelDefinitionService = [[AlfrescoModelDefinitionService alloc] initWithSession:self.currentSession];
        
        // retrieve type definition for cm:folder
        [self.modelDefinitionService retrieveDefinitionForFolderType:@"cm:folder" completionBlock:^(AlfrescoFolderTypeDefinition *typeDefinition, NSError *error) {
            if (typeDefinition == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:error];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertTrue([typeDefinition.name isEqualToString:@"cm:folder"],
                              @"Expected definition name to be 'cm:folder' but it was %@", typeDefinition.name);
                XCTAssertTrue([typeDefinition.title isEqualToString:@"Folder"],
                              @"Expected definition name to be 'Folder' but it was %@", typeDefinition.title);
                XCTAssertTrue([typeDefinition.summary isEqualToString:@"Folder Type"],
                              @"Expected definition name to be 'Folder Type' but it was %@", typeDefinition.summary);
                XCTAssertNil(typeDefinition.parent, @"Expected parent to be nil but it was %@", typeDefinition.parent);
                XCTAssertNotNil(typeDefinition.propertyNames, @"Expected propertyNames property to be populated");
                XCTAssertTrue(typeDefinition.propertyNames.count > 10,
                              @"Expected there to be more than 10 property names but there were %lu", (long)typeDefinition.propertyNames.count);
                
                if ([self.currentSession.repositoryInfo.majorVersion intValue] > 3)
                {
                    // NOTE: mandatory aspect data is not returned for 3.x servers
                    XCTAssertNotNil(typeDefinition.mandatoryAspects, @"Expected mandatoryAspects property to be populated");
                    XCTAssertTrue(typeDefinition.mandatoryAspects.count == 1,
                                  @"Expected there to be 1 mandatory aspect but there were %lu", (long)typeDefinition.mandatoryAspects.count);
                    XCTAssertTrue([typeDefinition.mandatoryAspects[0] isEqualToString:@"sys:localized"],
                                  @"Expected mandatory aspect entry to be sys:localized but it was %@", typeDefinition.mandatoryAspects[0]);
                }
                
                // check for a few property names
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cmis:name"], @"Expected the cmis:name property to be present");
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cmis:createdBy"], @"Expected the cmis:createdBy property to be present");
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cmis:creationDate"], @"Expected the cmis:creationDate property to be present");
                
                // retrieve and check some property definition objects
                AlfrescoPropertyDefinition *namePropertyDefiniton = [typeDefinition propertyDefinitionForPropertyWithName:@"cmis:name"];
                XCTAssertNotNil(namePropertyDefiniton, @"Expected to find a property definition for cmis:name");
                XCTAssertTrue([namePropertyDefiniton.name isEqualToString:@"cmis:name"],
                              @"Expected name to be 'cmis:name' but it was %@", namePropertyDefiniton.name);
                XCTAssertTrue([namePropertyDefiniton.title isEqualToString:@"Name"],
                              @"Expected title to be 'Name' but it was %@", namePropertyDefiniton.title);
                XCTAssertTrue([namePropertyDefiniton.summary isEqualToString:@"Name"],
                              @"Expected summary to be 'Name' but it was %@", namePropertyDefiniton.summary);
                XCTAssertTrue(namePropertyDefiniton.type == AlfrescoPropertyTypeString,
                              @"Expected type to be a string but it was %d", (int)namePropertyDefiniton.type);
                XCTAssertTrue(namePropertyDefiniton.isRequired, @"Expected isRequired to be true");
                XCTAssertFalse(namePropertyDefiniton.isReadOnly, @"Expected isReadOnly to be false");
                XCTAssertFalse(namePropertyDefiniton.isMultiValued, @"Expected isMultiValued to be false");
                XCTAssertNil(namePropertyDefiniton.defaultValue,
                             @"Expected default value to be nil but it was %@", namePropertyDefiniton.defaultValue);
                XCTAssertNil(namePropertyDefiniton.allowableValues,
                             @"Expected allowable values to be nil but it was %@", namePropertyDefiniton.allowableValues);
                
                AlfrescoPropertyDefinition *creationDatePropertyDefiniton = [typeDefinition propertyDefinitionForPropertyWithName:@"cmis:creationDate"];
                XCTAssertNotNil(creationDatePropertyDefiniton, @"Expected to find a property definition for cmis:creationDate");
                XCTAssertTrue([creationDatePropertyDefiniton.name isEqualToString:@"cmis:creationDate"],
                              @"Expected name to be 'cmis:creationDate' but it was %@", creationDatePropertyDefiniton.name);
                XCTAssertTrue([creationDatePropertyDefiniton.title isEqualToString:@"Creation Date"],
                              @"Expected title to be 'Creation Date' but it was %@", creationDatePropertyDefiniton.title);
                XCTAssertTrue([creationDatePropertyDefiniton.summary isEqualToString:@"The object creation date"],
                              @"Expected summary to be 'The object creation date' but it was %@", creationDatePropertyDefiniton.summary);
                XCTAssertTrue(creationDatePropertyDefiniton.type == AlfrescoPropertyTypeDateTime,
                              @"Expected type to be a date time but it was %d", (int)creationDatePropertyDefiniton.type);
                XCTAssertFalse(creationDatePropertyDefiniton.isRequired, @"Expected isRequired to be false");
                XCTAssertTrue(creationDatePropertyDefiniton.isReadOnly, @"Expected isReadOnly to be true");
                XCTAssertFalse(creationDatePropertyDefiniton.isMultiValued, @"Expected isMultiValued to be false");
                XCTAssertNil(creationDatePropertyDefiniton.defaultValue,
                             @"Expected default value to be nil but it was %@", creationDatePropertyDefiniton.defaultValue);
                XCTAssertNil(creationDatePropertyDefiniton.allowableValues,
                             @"Expected allowable values to be nil but it was %@", creationDatePropertyDefiniton.allowableValues);
                
                self.lastTestSuccessful = YES;
                self.callbackCompleted = YES;
            }
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrieveCustomTypeDefinition
{
    if (self.setUpSuccess)
    {
        // only run this test on-prem as custom types are not supported on the cloud yet
        if (!self.isCloud)
        {
            self.modelDefinitionService = [[AlfrescoModelDefinitionService alloc] initWithSession:self.currentSession];
        
            // retrieve type definition for cm:folder
            [self.modelDefinitionService retrieveDefinitionForDocumentType:@"fdk:everything" completionBlock:^(AlfrescoDocumentTypeDefinition *typeDefinition, NSError *error) {
                if (typeDefinition == nil)
                {
                    self.lastTestSuccessful = NO;
                    self.lastTestFailureMessage = [self failureMessageFromError:error];
                    self.callbackCompleted = YES;
                }
                else
                {
                    XCTAssertTrue([typeDefinition.name isEqualToString:@"fdk:everything"],
                                  @"Expected definition name to be 'fdk:everything' but it was %@", typeDefinition.name);
                    XCTAssertTrue([typeDefinition.parent isEqualToString:@"cm:content"],
                                  @"Expected definition parent to be 'cm:content' but it was %@", typeDefinition.parent);
                    XCTAssertNotNil(typeDefinition.propertyNames, @"Expected propertyNames property to be populated");
                    XCTAssertTrue(typeDefinition.propertyNames.count > 40,
                                  @"Expected there to be more than 40 property names but there were %lu", (long)typeDefinition.propertyNames.count);
                    
                    if ([self.currentSession.repositoryInfo.majorVersion intValue] == 3 ||
                        ([self.currentSession.repositoryInfo.majorVersion intValue] == 4 && [self.currentSession.repositoryInfo.minorVersion intValue] == 0))
                    {
                        XCTAssertTrue([typeDefinition.title isEqualToString:@"D:fdk:everything"],
                                      @"Expected definition name to be 'D:fdk:everything' but it was %@", typeDefinition.title);
                        XCTAssertTrue([typeDefinition.summary isEqualToString:@"D:fdk:everything"],
                                      @"Expected definition name to be 'D:fdk:everything' but it was %@", typeDefinition.summary);
                    }
                    else
                    {
                        XCTAssertTrue([typeDefinition.title isEqualToString:@"Everything"],
                                      @"Expected definition name to be 'Everything' but it was %@", typeDefinition.title);
                        XCTAssertTrue([typeDefinition.summary isEqualToString:@"Everything"],
                                      @"Expected definition name to be 'Everything' but it was %@", typeDefinition.summary);
                    }
                    
                    if ([self.currentSession.repositoryInfo.majorVersion intValue] > 3)
                    {
                        // NOTE: mandatory aspect data is not returned for 3.x servers
                        XCTAssertNotNil(typeDefinition.mandatoryAspects, @"Expected mandatoryAspects property to be populated");
                        XCTAssertTrue(typeDefinition.mandatoryAspects.count == 3,
                                      @"Expected there to be 3 mandatory aspect but there were %lu", (long)typeDefinition.mandatoryAspects.count);
                        XCTAssertTrue([typeDefinition.mandatoryAspects[0] isEqualToString:@"sys:localized"],
                                      @"Expected mandatory aspect entry to be sys:localized but it was %@", typeDefinition.mandatoryAspects[0]);
                        XCTAssertTrue([typeDefinition.mandatoryAspects[1] isEqualToString:@"cm:taggable"],
                                      @"Expected mandatory aspect entry to be cm:taggable but it was %@", typeDefinition.mandatoryAspects[1]);
                        XCTAssertTrue([typeDefinition.mandatoryAspects[2] isEqualToString:@"cm:generalclassifiable"],
                                      @"Expected mandatory aspect entry to be cm:generalclassifiable but it was %@", typeDefinition.mandatoryAspects[2]);
                    }
                    
                    // check for a few property names
                    XCTAssertTrue([typeDefinition.propertyNames containsObject:@"fdk:mandatory"], @"Expected the fdk:mandatory property to be present");
                    XCTAssertTrue([typeDefinition.propertyNames containsObject:@"fdk:boolean"], @"Expected the fdk:boolean property to be present");
                    XCTAssertTrue([typeDefinition.propertyNames containsObject:@"fdk:text"], @"Expected the fdk:text property to be present");
                    XCTAssertTrue([typeDefinition.propertyNames containsObject:@"fdk:long"], @"Expected the fdk:long property to be present");
                    XCTAssertTrue([typeDefinition.propertyNames containsObject:@"fdk:listConstraint"], @"Expected the fdk:listConstraint property to be present");
                    XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cmis:name"], @"Expected the cmis:name property to be present");
                    
                    // retrieve and check some property definition objects
                    AlfrescoPropertyDefinition *mandatoryPropertyDefiniton = [typeDefinition propertyDefinitionForPropertyWithName:@"fdk:mandatory"];
                    XCTAssertNotNil(mandatoryPropertyDefiniton, @"Expected to find a property definition for fdk:mandatory");
                    XCTAssertTrue([mandatoryPropertyDefiniton.name isEqualToString:@"fdk:mandatory"],
                                  @"Expected name to be 'fdk:mandatory' but it was %@", mandatoryPropertyDefiniton.name);
                    XCTAssertTrue([mandatoryPropertyDefiniton.title isEqualToString:@"fdk:mandatory"],
                                  @"Expected title to be 'fdk:mandatory' but it was %@", mandatoryPropertyDefiniton.title);
                    XCTAssertTrue([mandatoryPropertyDefiniton.summary isEqualToString:@"fdk:mandatory"],
                                  @"Expected summary to be 'fdk:mandatory' but it was %@", mandatoryPropertyDefiniton.summary);
                    XCTAssertTrue(mandatoryPropertyDefiniton.type == AlfrescoPropertyTypeString,
                                  @"Expected type to be a string but it was %d", (int)mandatoryPropertyDefiniton.type);
                    XCTAssertTrue(mandatoryPropertyDefiniton.isRequired, @"Expected isRequired to be true");
                    XCTAssertFalse(mandatoryPropertyDefiniton.isReadOnly, @"Expected isReadOnly to be false");
                    XCTAssertFalse(mandatoryPropertyDefiniton.isMultiValued, @"Expected isMultiValued to be false");
                    XCTAssertNil(mandatoryPropertyDefiniton.defaultValue,
                                 @"Expected default value to be nil but it was %@", mandatoryPropertyDefiniton.defaultValue);
                    XCTAssertNil(mandatoryPropertyDefiniton.allowableValues,
                                 @"Expected allowable values to be nil but it was %@", mandatoryPropertyDefiniton.allowableValues);
                    
                    AlfrescoPropertyDefinition *listConstraintPropertyDefiniton = [typeDefinition propertyDefinitionForPropertyWithName:@"fdk:listConstraint"];
                    XCTAssertNotNil(listConstraintPropertyDefiniton, @"Expected to find a property definition for fdk:listConstraint");
                    // add all values to a set and then check for existence (order is different on older servers);
                    NSArray *allowableValues = listConstraintPropertyDefiniton.allowableValues;
                    XCTAssertNotNil(allowableValues, @"Expected to find a set of allowable values");
                    NSMutableSet *allowableValuesSet = [NSMutableSet set];
                    for (NSDictionary *allowableValueDictionary in allowableValues)
                    {
                        [allowableValuesSet addObject:[allowableValueDictionary allKeys][0]];
                    }
                    XCTAssertTrue(allowableValuesSet.count == 3, @"Expected to find 3 allowable values but there were %lu", (unsigned long)allowableValuesSet.count);
                    XCTAssertTrue([allowableValuesSet containsObject:@"Phone"], @"Expected to find an allowable value of 'Phone'");
                    XCTAssertTrue([allowableValuesSet containsObject:@"Audio Visual"], @"Expected to find an allowable value of 'Audio Visual'");
                    XCTAssertTrue([allowableValuesSet containsObject:@"Computer"], @"Expected to find an allowable value of 'Computer'");
                    
                    AlfrescoPropertyDefinition *longPropertyDefiniton = [typeDefinition propertyDefinitionForPropertyWithName:@"fdk:long"];
                    XCTAssertNotNil(longPropertyDefiniton, @"Expected to find a property definition for fdk:long");
                    XCTAssertTrue(longPropertyDefiniton.type == AlfrescoPropertyTypeInteger,
                                  @"Expected type of fdk:long to be an integer but it was %d", (int)longPropertyDefiniton.type);
                    
                    AlfrescoPropertyDefinition *doublePropertyDefiniton = [typeDefinition propertyDefinitionForPropertyWithName:@"fdk:double"];
                    XCTAssertNotNil(doublePropertyDefiniton, @"Expected to find a property definition for fdk:double");
                    XCTAssertTrue(doublePropertyDefiniton.type == AlfrescoPropertyTypeDecimal,
                                  @"Expected type of fdk:double to be a decimal but it was %d", (int)doublePropertyDefiniton.type);
                    
                    AlfrescoPropertyDefinition *datePropertyDefiniton = [typeDefinition propertyDefinitionForPropertyWithName:@"fdk:date"];
                    XCTAssertNotNil(datePropertyDefiniton, @"Expected to find a property definition for fdk:date");
                    XCTAssertTrue(datePropertyDefiniton.type == AlfrescoPropertyTypeDateTime,
                                  @"Expected type of fdk:date to be a date but it was %d", (int)datePropertyDefiniton.type);
                    
                    AlfrescoPropertyDefinition *noderefPropertyDefiniton = [typeDefinition propertyDefinitionForPropertyWithName:@"fdk:noderef"];
                    XCTAssertNotNil(noderefPropertyDefiniton, @"Expected to find a property definition for fdk:noderef");
                    XCTAssertTrue(noderefPropertyDefiniton.type == AlfrescoPropertyTypeId,
                                  @"Expected type of fdk:noderef to be an id but it was %d", (int)noderefPropertyDefiniton.type);
                    
                    AlfrescoPropertyDefinition *boolPropertyDefiniton = [typeDefinition propertyDefinitionForPropertyWithName:@"fdk:boolean"];
                    XCTAssertNotNil(boolPropertyDefiniton, @"Expected to find a property definition for fdk:boolean");
                    XCTAssertTrue(boolPropertyDefiniton.type == AlfrescoPropertyTypeBoolean,
                                  @"Expected type of fdk:boolean to be a boolean but it was %d", (int)boolPropertyDefiniton.type);
                    
                    AlfrescoPropertyDefinition *multiValuedPropertyDefiniton = [typeDefinition propertyDefinitionForPropertyWithName:@"fdk:textMultiple"];
                    XCTAssertNotNil(multiValuedPropertyDefiniton, @"Expected to find a property definition for fdk:textMultiple");
                    XCTAssertTrue(multiValuedPropertyDefiniton.isMultiValued, @"Expected isMultiValued to be true");
                    
                    self.lastTestSuccessful = YES;
                    self.callbackCompleted = YES;
                }
            }];
            
            [self waitUntilCompleteWithFixedTimeInterval];
            XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
        }
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrieveAspectDefinition
{
    if (self.setUpSuccess)
    {
        self.modelDefinitionService = [[AlfrescoModelDefinitionService alloc] initWithSession:self.currentSession];
        
        // retrieve aspect definition for cm:exif
        [self.modelDefinitionService retrieveDefinitionForAspect:@"exif:exif" completionBlock:^(AlfrescoAspectDefinition *aspectDefinition, NSError *error) {
            if (aspectDefinition == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:error];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertTrue([aspectDefinition.name isEqualToString:@"exif:exif"],
                              @"Expected definition name to be 'exif:exif' but it was %@", aspectDefinition.name);
                XCTAssertTrue([aspectDefinition.title isEqualToString:@"EXIF"],
                              @"Expected definition title to be 'EXIF' but it was %@", aspectDefinition.title);
                XCTAssertTrue([aspectDefinition.summary isEqualToString:@"Subset of the standard EXIF metadata"],
                              @"Expected definition summary to be 'Subset of the standard EXIF metadata' but it was %@", aspectDefinition.summary);
                XCTAssertNil(aspectDefinition.parent, @"Expected parent to be nil but it was %@", aspectDefinition.parent);
                XCTAssertNotNil(aspectDefinition.propertyNames, @"Expected propertyNames property to be populated");
                XCTAssertTrue(aspectDefinition.propertyNames.count >= 15,
                              @"Expected there to be 15 or more property names but there were %lu", (long)aspectDefinition.propertyNames.count);
                
                // check for a few property names
                XCTAssertTrue([aspectDefinition.propertyNames containsObject:@"exif:xResolution"], @"Expected the exif:xResolution property to be present");
                XCTAssertTrue([aspectDefinition.propertyNames containsObject:@"exif:yResolution"], @"Expected the exif:yResolution property to be present");
                XCTAssertTrue([aspectDefinition.propertyNames containsObject:@"exif:software"], @"Expected the exif:software property to be present");
                
                // retrieve and check some property definition objects
                AlfrescoPropertyDefinition *xResolutionPropertyDefiniton = [aspectDefinition propertyDefinitionForPropertyWithName:@"exif:xResolution"];
                XCTAssertNotNil(xResolutionPropertyDefiniton, @"Expected to find a property definition for exif:xResolution");
                XCTAssertTrue([xResolutionPropertyDefiniton.name isEqualToString:@"exif:xResolution"],
                              @"Expected name to be 'exif:xResolution' but it was %@", xResolutionPropertyDefiniton.name);
                XCTAssertTrue([xResolutionPropertyDefiniton.title isEqualToString:@"Horizontal Resolution"],
                              @"Expected title to be 'Horizontal Resolution' but it was %@", xResolutionPropertyDefiniton.title);
                XCTAssertTrue([xResolutionPropertyDefiniton.summary isEqualToString:@"Horizontal resolution in pixels per unit"],
                              @"Expected summary to be 'Horizontal resolution in pixels per unit' but it was %@", xResolutionPropertyDefiniton.summary);
                XCTAssertTrue(xResolutionPropertyDefiniton.type == AlfrescoPropertyTypeDecimal,
                              @"Expected type to be a decimal but it was %d", (int)xResolutionPropertyDefiniton.type);
                XCTAssertFalse(xResolutionPropertyDefiniton.isRequired, @"Expected isRequired to be false");
                XCTAssertFalse(xResolutionPropertyDefiniton.isReadOnly, @"Expected isReadOnly to be false");
                XCTAssertFalse(xResolutionPropertyDefiniton.isMultiValued, @"Expected isMultiValued to be false");
                XCTAssertNil(xResolutionPropertyDefiniton.defaultValue,
                             @"Expected default value to be nil but it was %@", xResolutionPropertyDefiniton.defaultValue);
                XCTAssertNil(xResolutionPropertyDefiniton.allowableValues,
                             @"Expected allowable values to be nil but it was %@", xResolutionPropertyDefiniton.allowableValues);
                
                self.lastTestSuccessful = YES;
                self.callbackCompleted = YES;
            }
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrieveTaskDefinition
{
    if (self.setUpSuccess)
    {
        // only run this test on-prem as task types are not exposed on the cloud yet
        if (!self.isCloud)
        {
            self.modelDefinitionService = [[AlfrescoModelDefinitionService alloc] initWithSession:self.currentSession];
            
            // retrieve task definition for wf:adhocTask
            [self.modelDefinitionService retrieveDefinitionForTaskType:@"wf:adhocTask" completionBlock:^(AlfrescoTaskTypeDefinition *taskDefinition, NSError *error) {
                if (taskDefinition == nil)
                {
                    self.lastTestSuccessful = NO;
                    self.lastTestFailureMessage = [self failureMessageFromError:error];
                    self.callbackCompleted = YES;
                }
                else
                {
                    XCTAssertTrue([taskDefinition.name isEqualToString:@"wf:adhocTask"],
                                  @"Expected definition name to be 'wf:adhocTask' but it was %@", taskDefinition.name);
                    if ([self.currentSession.repositoryInfo.majorVersion intValue] > 4 ||
                        ([self.currentSession.repositoryInfo.majorVersion intValue] == 4 && [self.currentSession.repositoryInfo.minorVersion intValue] > 1))
                    {
                        XCTAssertTrue([taskDefinition.title isEqualToString:@"Task"],
                                      @"Expected definition title to be 'Task' but it was %@", taskDefinition.title);
                        XCTAssertTrue([taskDefinition.summary isEqualToString:@"Task allocated by colleague"],
                                      @"Expected definition summary to be 'Task allocated by colleague' but it was %@", taskDefinition.summary);
                    }
                    else
                    {
                        XCTAssertTrue([taskDefinition.title isEqualToString:@"Adhoc Task"],
                                      @"Expected definition title to be 'Adhoc Task' but it was %@", taskDefinition.title);
                        XCTAssertTrue([taskDefinition.summary isEqualToString:@"Adhoc Task allocated by colleague"],
                                      @"Expected definition summary to be 'Adhoc Task allocated by colleague' but it was %@", taskDefinition.summary);
                    }
                    XCTAssertTrue([taskDefinition.parent isEqualToString:@"bpm:workflowTask"],
                                  @"Expected definition parent to be 'bpm:workflowTask' but it was %@", taskDefinition.parent);
                    XCTAssertNotNil(taskDefinition.propertyNames, @"Expected propertyNames property to be populated");
                    XCTAssertTrue(taskDefinition.propertyNames.count > 35,
                                  @"Expected there to be more than 35 property names but there were %lu", (long)taskDefinition.propertyNames.count);
                    
                    // check for a few property names
                    XCTAssertTrue([taskDefinition.propertyNames containsObject:@"bpm:packageActionGroup"],
                                  @"Expected the bpm:packageActionGroup property to be present");
                    XCTAssertTrue([taskDefinition.propertyNames containsObject:@"bpm:packageItemActionGroup"],
                                  @"Expected the bpm:packageItemActionGroup property to be present");
                    XCTAssertTrue([taskDefinition.propertyNames containsObject:@"bpm:status"],
                                  @"Expected the bpm:status property to be present");
                    
                    // retrieve and check bpm:status property definition
                    AlfrescoPropertyDefinition *statusPropertyDefiniton = [taskDefinition propertyDefinitionForPropertyWithName:@"bpm:status"];
                    XCTAssertNotNil(statusPropertyDefiniton, @"Expected to find a property definition for bpm:status");
                    XCTAssertTrue([statusPropertyDefiniton.name isEqualToString:@"bpm:status"],
                                  @"Expected name to be 'bpm:status' but it was %@", statusPropertyDefiniton.name);
                    XCTAssertTrue([statusPropertyDefiniton.title isEqualToString:@"Status"],
                                  @"Expected title to be 'Status' but it was %@", statusPropertyDefiniton.title);
                    XCTAssertTrue([statusPropertyDefiniton.summary isEqualToString:@"Status"],
                                  @"Expected summary to be 'Status' but it was %@", statusPropertyDefiniton.summary);
                    XCTAssertTrue(statusPropertyDefiniton.isRequired, @"Expected isRequired to be true");
                    XCTAssertFalse(statusPropertyDefiniton.isReadOnly, @"Expected isReadOnly to be false");
                    XCTAssertFalse(statusPropertyDefiniton.isMultiValued, @"Expected isMultiValued to be false");
                    XCTAssertTrue([statusPropertyDefiniton.defaultValue isEqualToString:@"Not Yet Started"],
                                  @"Expected default value to be 'Not Yet Started' but it was %@", statusPropertyDefiniton.defaultValue);
                    XCTAssertNotNil(statusPropertyDefiniton.allowableValues, @"Expected allowable values to be set");
                    XCTAssertTrue(statusPropertyDefiniton.allowableValues.count == 5,
                                  @"Expected there to be 5 allowable values but there were %lu", (long)statusPropertyDefiniton.allowableValues.count);
                    
                    self.lastTestSuccessful = YES;
                    self.callbackCompleted = YES;
                }
            }];
            
            [self waitUntilCompleteWithFixedTimeInterval];
            XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
        }
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testInvalidDefinitionNames
{
    if (self.setUpSuccess)
    {
        self.modelDefinitionService = [[AlfrescoModelDefinitionService alloc] initWithSession:self.currentSession];
        
        // make sure an invalid document type name gives an error
        [self.modelDefinitionService retrieveDefinitionForDocumentType:@"invalid:type" completionBlock:^(AlfrescoDocumentTypeDefinition *docTypeDefinition, NSError *docTypeDefError) {
            if (docTypeDefinition == nil)
            {
                // make sure the error is as expected
                XCTAssertNotNil(docTypeDefError, @"Expected to recieve an error");
                XCTAssertTrue(docTypeDefError.code == kAlfrescoErrorCodeModelDefinitionNotFound,
                              @"Expected the error code to be 1301 but was %lu", (unsigned long)docTypeDefError.code);
                
                // make sure an invalid folder type name gives an error
                [self.modelDefinitionService retrieveDefinitionForFolderType:@"invalid:type" completionBlock:^(AlfrescoFolderTypeDefinition *folderTypeDefinition, NSError *folderTypeDefError) {
                    if (folderTypeDefinition == nil)
                    {
                        // make sure the error is as expected
                        XCTAssertNotNil(folderTypeDefError, @"Expected to recieve an error");
                        XCTAssertTrue(folderTypeDefError.code == kAlfrescoErrorCodeModelDefinitionNotFound,
                                      @"Expected the error code to be 1301 but was %lu", (unsigned long)folderTypeDefError.code);
                        
                        // make sure an invalid aspect name gives an error
                        [self.modelDefinitionService retrieveDefinitionForAspect:@"invalid:type" completionBlock:^(AlfrescoAspectDefinition *aspectDefinition, NSError *aspectDefError) {
                            if (aspectDefinition == nil)
                            {
                                // make sure the error is as expected
                                XCTAssertNotNil(aspectDefError, @"Expected to recieve an error");
                                XCTAssertTrue(aspectDefError.code == kAlfrescoErrorCodeModelDefinitionNotFound,
                                              @"Expected the error code to be 1301 but was %lu", (unsigned long)aspectDefError.code);
                                
                                self.lastTestSuccessful = YES;
                                self.callbackCompleted = YES;
                            }
                            else
                            {
                                self.lastTestSuccessful = NO;
                                self.lastTestFailureMessage = @"Expected to fail getting an invalid aspect definition";
                                self.callbackCompleted = YES;
                            }
                        }];
                    }
                    else
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = @"Expected to fail getting an invalid folder type definition";
                        self.callbackCompleted = YES;
                    }
                }];
            }
            else
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = @"Expected to fail getting an invalid document type definition";
                self.callbackCompleted = YES;
            }
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrieveDefinitionFromDocument
{
    if (self.setUpSuccess)
    {
        self.modelDefinitionService = [[AlfrescoModelDefinitionService alloc] initWithSession:self.currentSession];
        
        
        NSLog(@"There are %lu aspects on the test folder", (unsigned long)self.testDocFolder.aspects.count);
        
        
        // retrieve type definition for cm:content
        [self.modelDefinitionService retrieveDefinitionForDocument:self.testAlfrescoDocument completionBlock:^(AlfrescoDocumentTypeDefinition *typeDefinition, NSError *error) {
            if (typeDefinition == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:error];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertTrue([typeDefinition.name isEqualToString:@"cm:content"],
                              @"Expected definition name to be 'cm:content' but it was %@", typeDefinition.name);
                XCTAssertTrue([typeDefinition.title isEqualToString:@"Document"],
                              @"Expected definition name to be 'Document' but it was %@", typeDefinition.title);
                XCTAssertTrue([typeDefinition.summary isEqualToString:@"Document Type"],
                              @"Expected definition name to be 'Document Type' but it was %@", typeDefinition.summary);
                XCTAssertNil(typeDefinition.parent, @"Expected parent to be nil but it was %@", typeDefinition.parent);
                XCTAssertNotNil(typeDefinition.propertyNames, @"Expected propertyNames property to be populated");
                XCTAssertTrue(typeDefinition.propertyNames.count > 25,
                              @"Expected there to be more than 25 property names but there were %lu", (long)typeDefinition.propertyNames.count);
                
                if ([self.currentSession.repositoryInfo.majorVersion intValue] > 3)
                {
                    // NOTE: mandatory aspect data is not returned for 3.x servers
                    XCTAssertNotNil(typeDefinition.mandatoryAspects, @"Expected mandatoryAspects property to be populated");
                    XCTAssertTrue(typeDefinition.mandatoryAspects.count == 1,
                                  @"Expected there to be 1 mandatory aspect but there were %lu", (long)typeDefinition.mandatoryAspects.count);
                    XCTAssertTrue([typeDefinition.mandatoryAspects[0] isEqualToString:@"sys:localized"],
                                  @"Expected mandatory aspect entry to be sys:localized but it was %@", typeDefinition.mandatoryAspects[0]);
                }
                
                // check for a few property names
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cmis:name"], @"Expected the cmis:name property to be present");
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cmis:createdBy"], @"Expected the cmis:createdBy property to be present");
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cmis:creationDate"], @"Expected the cmis:creationDate property to be present");
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cm:title"], @"Expected the cm:title property to be present");
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cm:description"], @"Expected the cm:description property to be present");
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cm:author"], @"Expected the cm:author property to be present");
                
                // check the cm:title property is properly populated
                AlfrescoPropertyDefinition *titlePropertyDefiniton = [typeDefinition propertyDefinitionForPropertyWithName:@"cm:title"];
                XCTAssertNotNil(titlePropertyDefiniton, @"Expected to find a property definition for cm:title");
                XCTAssertTrue([titlePropertyDefiniton.name isEqualToString:@"cm:title"],
                              @"Expected name to be 'cm:title' but it was %@", titlePropertyDefiniton.name);
                XCTAssertTrue([titlePropertyDefiniton.title isEqualToString:@"Title"],
                              @"Expected title to be 'Title' but it was %@", titlePropertyDefiniton.title);
                XCTAssertTrue([titlePropertyDefiniton.summary isEqualToString:@"Content Title"],
                              @"Expected summary to be 'Content Title' but it was %@", titlePropertyDefiniton.summary);
                XCTAssertTrue(titlePropertyDefiniton.type == AlfrescoPropertyTypeString,
                              @"Expected type to be a string but it was %d", (int)titlePropertyDefiniton.type);
                XCTAssertFalse(titlePropertyDefiniton.isRequired, @"Expected isRequired to be false");
                XCTAssertFalse(titlePropertyDefiniton.isReadOnly, @"Expected isReadOnly to be false");
                XCTAssertFalse(titlePropertyDefiniton.isMultiValued, @"Expected isMultiValued to be false");
                
                self.lastTestSuccessful = YES;
                self.callbackCompleted = YES;
            }
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrieveDefinitionFromFolder
{
    if (self.setUpSuccess)
    {
        self.modelDefinitionService = [[AlfrescoModelDefinitionService alloc] initWithSession:self.currentSession];
        
        // retrieve type definition for folder object
        [self.modelDefinitionService retrieveDefinitionForFolder:self.testDocFolder completionBlock:^(AlfrescoFolderTypeDefinition *typeDefinition, NSError *error) {
            if (typeDefinition == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:error];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertTrue([typeDefinition.name isEqualToString:@"cm:folder"],
                              @"Expected definition name to be 'cm:folder' but it was %@", typeDefinition.name);
                XCTAssertTrue([typeDefinition.title isEqualToString:@"Folder"],
                              @"Expected definition name to be 'Folder' but it was %@", typeDefinition.title);
                XCTAssertTrue([typeDefinition.summary isEqualToString:@"Folder Type"],
                              @"Expected definition name to be 'Folder Type' but it was %@", typeDefinition.summary);
                XCTAssertNil(typeDefinition.parent, @"Expected parent to be nil but it was %@", typeDefinition.parent);
                XCTAssertNotNil(typeDefinition.propertyNames, @"Expected propertyNames property to be populated");
                XCTAssertTrue(typeDefinition.propertyNames.count > 10,
                              @"Expected there to be more than 10 property names but there were %lu", (long)typeDefinition.propertyNames.count);
                
                if ([self.currentSession.repositoryInfo.majorVersion intValue] > 3)
                {
                    // NOTE: mandatory aspect data is not returned for 3.x servers
                    XCTAssertNotNil(typeDefinition.mandatoryAspects, @"Expected mandatoryAspects property to be populated");
                    XCTAssertTrue(typeDefinition.mandatoryAspects.count == 1,
                                  @"Expected there to be 1 mandatory aspect but there were %lu", (long)typeDefinition.mandatoryAspects.count);
                    XCTAssertTrue([typeDefinition.mandatoryAspects[0] isEqualToString:@"sys:localized"],
                                  @"Expected mandatory aspect entry to be sys:localized but it was %@", typeDefinition.mandatoryAspects[0]);
                }
                
                // check for a few property names
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cmis:name"], @"Expected the cmis:name property to be present");
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cmis:createdBy"], @"Expected the cmis:createdBy property to be present");
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cmis:creationDate"], @"Expected the cmis:creationDate property to be present");
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cm:title"], @"Expected the cm:title property to be present");
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cm:description"], @"Expected the cm:description property to be present");
                
                // check the cm:title property is properly populated
                AlfrescoPropertyDefinition *titlePropertyDefiniton = [typeDefinition propertyDefinitionForPropertyWithName:@"cm:title"];
                XCTAssertNotNil(titlePropertyDefiniton, @"Expected to find a property definition for cm:title");
                XCTAssertTrue([titlePropertyDefiniton.name isEqualToString:@"cm:title"],
                              @"Expected name to be 'cm:title' but it was %@", titlePropertyDefiniton.name);
                XCTAssertTrue([titlePropertyDefiniton.title isEqualToString:@"Title"],
                              @"Expected title to be 'Title' but it was %@", titlePropertyDefiniton.title);
                XCTAssertTrue([titlePropertyDefiniton.summary isEqualToString:@"Content Title"],
                              @"Expected summary to be 'Content Title' but it was %@", titlePropertyDefiniton.summary);
                XCTAssertTrue(titlePropertyDefiniton.type == AlfrescoPropertyTypeString,
                              @"Expected type to be a string but it was %d", (int)titlePropertyDefiniton.type);
                XCTAssertFalse(titlePropertyDefiniton.isRequired, @"Expected isRequired to be false");
                XCTAssertFalse(titlePropertyDefiniton.isReadOnly, @"Expected isReadOnly to be false");
                XCTAssertFalse(titlePropertyDefiniton.isMultiValued, @"Expected isMultiValued to be false");
                
                self.lastTestSuccessful = YES;
                self.callbackCompleted = YES;
            }
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrieveDefinitionFromTask
{
    if (self.setUpSuccess)
    {
        // only run this test on-prem as task types are not exposed on the cloud yet
        if (!self.isCloud)
        {
            // retrieve any task
            AlfrescoWorkflowService *workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
            [workflowService retrieveTasksWithCompletionBlock:^(NSArray *tasks, NSError *tasksError) {
                if (tasks == nil)
                {
                    self.lastTestSuccessful = NO;
                    self.lastTestFailureMessage = [self failureMessageFromError:tasksError];
                    self.callbackCompleted = YES;
                }
                else
                {
                    XCTAssertTrue(tasks.count > 0, @"Expected to find at least one task");
                    AlfrescoWorkflowTask *task = tasks[0];
                    
                    self.modelDefinitionService = [[AlfrescoModelDefinitionService alloc] initWithSession:self.currentSession];
                    [self.modelDefinitionService retrieveDefinitionForTask:task completionBlock:^(AlfrescoTaskTypeDefinition *taskDefinition, NSError *definitionError) {
                        if (taskDefinition == nil)
                        {
                            self.lastTestSuccessful = NO;
                            self.lastTestFailureMessage = [self failureMessageFromError:definitionError];
                            self.callbackCompleted = YES;
                        }
                        else
                        {
                            // check the type definition matches the task
                            XCTAssertTrue([task.type isEqualToString:taskDefinition.name],
                                          @"Expected the type definition name to match the task type");
                            
                            // check for a few property names
                            XCTAssertTrue([taskDefinition.propertyNames containsObject:@"bpm:packageActionGroup"],
                                          @"Expected the bpm:packageActionGroup property to be present");
                            XCTAssertTrue([taskDefinition.propertyNames containsObject:@"bpm:packageItemActionGroup"],
                                          @"Expected the bpm:packageItemActionGroup property to be present");
                            XCTAssertTrue([taskDefinition.propertyNames containsObject:@"bpm:status"],
                                          @"Expected the bpm:status property to be present");
                            XCTAssertTrue([taskDefinition.propertyNames containsObject:@"bpm:comment"],
                                          @"Expected the bpm:comment property to be present");
                            XCTAssertTrue([taskDefinition.propertyNames containsObject:@"bpm:description"],
                                          @"Expected the bpm:description property to be present");
                            
                            self.lastTestSuccessful = YES;
                            self.callbackCompleted = YES;
                        }
                    }];
                }
            }];
            
            [self waitUntilCompleteWithFixedTimeInterval];
            XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
        }
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

@end

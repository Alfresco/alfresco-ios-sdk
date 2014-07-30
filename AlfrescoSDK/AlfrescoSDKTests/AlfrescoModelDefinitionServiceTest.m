/*******************************************************************************
 * Copyright (C) 2005-2014 Alfresco Software Limited.
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
//                XCTAssertNotNil(typeDefinition.mandatoryAspects, @"Expected mandatoryAspects property to be populated");
                XCTAssertTrue(typeDefinition.propertyNames.count == 26,
                              @"Expected there to be 26 property names but there were %lu", (long)typeDefinition.propertyNames.count);
//                XCTAssertTrue(typeDefinition.mandatoryAspects.count == 1,
//                              @"Expected there to be 1 mandatory aspect but there were %lu", (long)typeDefinition.mandatoryAspects.count);
                
                // check for a few property names
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cmis:name"], @"Expected the cmis:name property to be present");
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cmis:description"], @"Expected the cmis:description property to be present");
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cmis:createdBy"], @"Expected the cmis:createdBy property to be present");
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cmis:creationDate"], @"Expected the cmis:creationDate property to be present");
                
                // check the mandatory aspect is expected
//                XCTAssertTrue([typeDefinition.mandatoryAspects[0] isEqualToString:@"sys:localized"],
//                              @"Expected mandatory aspect entry to be sys:localized but it was %@", typeDefinition.mandatoryAspects[0]);
                
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
                              @"Expected type to be a string but it was %ld", namePropertyDefiniton.type);
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
                              @"Expected type to be a date time but it was %ld", creationDatePropertyDefiniton.type);
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
//                XCTAssertNotNil(typeDefinition.mandatoryAspects, @"Expected mandatoryAspects property to be populated");
                XCTAssertTrue(typeDefinition.propertyNames.count == 14,
                              @"Expected there to be 14 property names but there were %lu", (long)typeDefinition.propertyNames.count);
//                XCTAssertTrue(typeDefinition.mandatoryAspects.count == 1,
//                              @"Expected there to be 1 mandatory aspect but there were %lu", (long)typeDefinition.mandatoryAspects.count);
                
                // check for a few property names
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cmis:name"], @"Expected the cmis:name property to be present");
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cmis:description"], @"Expected the cmis:description property to be present");
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cmis:createdBy"], @"Expected the cmis:createdBy property to be present");
                XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cmis:creationDate"], @"Expected the cmis:creationDate property to be present");
                
                // check the mandatory aspect is expected
//                XCTAssertTrue([typeDefinition.mandatoryAspects[0] isEqualToString:@"sys:localized"],
//                              @"Expected mandatory aspect entry to be sys:localized but it was %@", typeDefinition.mandatoryAspects[0]);
                
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
                              @"Expected type to be a string but it was %ld", namePropertyDefiniton.type);
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
                              @"Expected type to be a date time but it was %ld", creationDatePropertyDefiniton.type);
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
                    XCTAssertTrue([typeDefinition.title isEqualToString:@"Everything"],
                                  @"Expected definition name to be 'Everything' but it was %@", typeDefinition.title);
                    XCTAssertTrue([typeDefinition.summary isEqualToString:@"Everything"],
                                  @"Expected definition name to be 'Everything' but it was %@", typeDefinition.summary);
//                    XCTAssertTrue([typeDefinition.parent isEqualToString:@"cm:content"],
//                                  @"Expected definition parent to be 'cm:content' but it was %@", typeDefinition.parent);
                    XCTAssertNotNil(typeDefinition.propertyNames, @"Expected propertyNames property to be populated");
//                    XCTAssertNotNil(typeDefinition.mandatoryAspects, @"Expected mandatoryAspects property to be populated");
                    XCTAssertTrue(typeDefinition.propertyNames.count == 48,
                                  @"Expected there to be 48 property names but there were %lu", (long)typeDefinition.propertyNames.count);
//                    XCTAssertTrue(typeDefinition.mandatoryAspects.count == 1,
//                                  @"Expected there to be 1 mandatory aspect but there were %lu", (long)typeDefinition.mandatoryAspects.count);
                    
                    // check for a few property names
                    XCTAssertTrue([typeDefinition.propertyNames containsObject:@"fdk:mandatory"], @"Expected the fdk:mandatory property to be present");
                    XCTAssertTrue([typeDefinition.propertyNames containsObject:@"fdk:boolean"], @"Expected the fdk:boolean property to be present");
                    XCTAssertTrue([typeDefinition.propertyNames containsObject:@"fdk:text"], @"Expected the fdk:text property to be present");
                    XCTAssertTrue([typeDefinition.propertyNames containsObject:@"fdk:long"], @"Expected the fdk:long property to be present");
                    XCTAssertTrue([typeDefinition.propertyNames containsObject:@"fdk:listConstraint"], @"Expected the fdk:listConstraint property to be present");
                    XCTAssertTrue([typeDefinition.propertyNames containsObject:@"cmis:name"], @"Expected the cmis:name property to be present");
                    
                    // check the mandatory aspect is expected
//                    XCTAssertTrue([typeDefinition.mandatoryAspects[0] isEqualToString:@"cm:generalclassifiable"],
//                                  @"Expected mandatory aspect entry to be cm:generalclassifiable but it was %@", typeDefinition.mandatoryAspects[0]);
                    
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
                                  @"Expected type to be a string but it was %ld", mandatoryPropertyDefiniton.type);
                    XCTAssertTrue(mandatoryPropertyDefiniton.isRequired, @"Expected isRequired to be true");
                    XCTAssertFalse(mandatoryPropertyDefiniton.isReadOnly, @"Expected isReadOnly to be false");
                    XCTAssertFalse(mandatoryPropertyDefiniton.isMultiValued, @"Expected isMultiValued to be false");
                    XCTAssertNil(mandatoryPropertyDefiniton.defaultValue,
                                 @"Expected default value to be nil but it was %@", mandatoryPropertyDefiniton.defaultValue);
                    XCTAssertNil(mandatoryPropertyDefiniton.allowableValues,
                                 @"Expected allowable values to be nil but it was %@", mandatoryPropertyDefiniton.allowableValues);
                    
                    AlfrescoPropertyDefinition *listConstraintPropertyDefiniton = [typeDefinition propertyDefinitionForPropertyWithName:@"fdk:listConstraint"];
                    XCTAssertNotNil(listConstraintPropertyDefiniton, @"Expected to find a property definition for fdk:listConstraint");
//                    NSArray *allowableValues = listConstraintPropertyDefiniton.allowableValues;
//                    XCTAssertNotNil(allowableValues, @"Expected to find a set of allowable values");
//                    NSDictionary *option1 = allowableValues[0];
//                    XCTAssertNotNil(option1[@"Phone"], @"Expected the first allowable value to be 'Phone'");
//                    NSDictionary *option2 = allowableValues[1];
//                    XCTAssertNotNil(option2[@"Audio Visual"], @"Expected the second allowable value to be 'Audio Visual'");
//                    NSDictionary *option3 = allowableValues[2];
//                    XCTAssertNotNil(option3[@"Computer"], @"Expected the third allowable value to be 'Computer'");
                    
                    AlfrescoPropertyDefinition *longPropertyDefiniton = [typeDefinition propertyDefinitionForPropertyWithName:@"fdk:long"];
                    XCTAssertNotNil(longPropertyDefiniton, @"Expected to find a property definition for fdk:long");
                    XCTAssertTrue(longPropertyDefiniton.type == AlfrescoPropertyTypeInteger,
                                  @"Expected type of fdk:long to be an integer but it was %ld", longPropertyDefiniton.type);
                    
                    AlfrescoPropertyDefinition *doublePropertyDefiniton = [typeDefinition propertyDefinitionForPropertyWithName:@"fdk:double"];
                    XCTAssertNotNil(doublePropertyDefiniton, @"Expected to find a property definition for fdk:double");
                    XCTAssertTrue(doublePropertyDefiniton.type == AlfrescoPropertyTypeDecimal,
                                  @"Expected type of fdk:double to be a decimal but it was %ld", doublePropertyDefiniton.type);
                    
                    AlfrescoPropertyDefinition *datePropertyDefiniton = [typeDefinition propertyDefinitionForPropertyWithName:@"fdk:date"];
                    XCTAssertNotNil(datePropertyDefiniton, @"Expected to find a property definition for fdk:date");
                    XCTAssertTrue(datePropertyDefiniton.type == AlfrescoPropertyTypeDateTime,
                                  @"Expected type of fdk:date to be a date but it was %ld", datePropertyDefiniton.type);
                    
                    AlfrescoPropertyDefinition *noderefPropertyDefiniton = [typeDefinition propertyDefinitionForPropertyWithName:@"fdk:noderef"];
                    XCTAssertNotNil(noderefPropertyDefiniton, @"Expected to find a property definition for fdk:noderef");
                    XCTAssertTrue(noderefPropertyDefiniton.type == AlfrescoPropertyTypeId,
                                  @"Expected type of fdk:noderef to be an id but it was %ld", noderefPropertyDefiniton.type);
                    
                    AlfrescoPropertyDefinition *boolPropertyDefiniton = [typeDefinition propertyDefinitionForPropertyWithName:@"fdk:boolean"];
                    XCTAssertNotNil(boolPropertyDefiniton, @"Expected to find a property definition for fdk:boolean");
                    XCTAssertTrue(boolPropertyDefiniton.type == AlfrescoPropertyTypeBoolean,
                                  @"Expected type of fdk:boolean to be a boolean but it was %ld", boolPropertyDefiniton.type);
                    
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
                              @"Expected definition name to be 'EXIF' but it was %@", aspectDefinition.title);
                XCTAssertTrue([aspectDefinition.summary isEqualToString:@"Subset of the standard EXIF metadata"],
                              @"Expected definition name to be 'Subset of the standard EXIF metadata' but it was %@", aspectDefinition.summary);
                XCTAssertNil(aspectDefinition.parent, @"Expected parent to be nil but it was %@", aspectDefinition.parent);
                XCTAssertNotNil(aspectDefinition.propertyNames, @"Expected propertyNames property to be populated");
                XCTAssertTrue(aspectDefinition.propertyNames.count == 27,
                              @"Expected there to be 27 property names but there were %lu", (long)aspectDefinition.propertyNames.count);
                
                // check for a few property names
                XCTAssertTrue([aspectDefinition.propertyNames containsObject:@"exif:xResolution"], @"Expected the exif:xResolution property to be present");
                XCTAssertTrue([aspectDefinition.propertyNames containsObject:@"exif:yResolution"], @"Expected the exif:yResolution property to be present");
                XCTAssertTrue([aspectDefinition.propertyNames containsObject:@"exif:software"], @"Expected the exif:software property to be present");
                XCTAssertTrue([aspectDefinition.propertyNames containsObject:@"cmis:name"], @"Expected the cmis:name property to be present");
                
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
                              @"Expected type to be a decimal but it was %ld", xResolutionPropertyDefiniton.type);
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
                              @"Expected the error code to be 1301 but was %lu", docTypeDefError.code);
                
                // make sure an invalid folder type name gives an error
                [self.modelDefinitionService retrieveDefinitionForFolderType:@"invalid:type" completionBlock:^(AlfrescoFolderTypeDefinition *folderTypeDefinition, NSError *folderTypeDefError) {
                    if (folderTypeDefinition == nil)
                    {
                        // make sure the error is as expected
                        XCTAssertNotNil(folderTypeDefError, @"Expected to recieve an error");
                        XCTAssertTrue(folderTypeDefError.code == kAlfrescoErrorCodeModelDefinitionNotFound,
                                      @"Expected the error code to be 1301 but was %lu", folderTypeDefError.code);
                        
                        // make sure an invalid aspect name gives an error
                        [self.modelDefinitionService retrieveDefinitionForAspect:@"invalid:type" completionBlock:^(AlfrescoAspectDefinition *aspectDefinition, NSError *aspectDefError) {
                            if (aspectDefinition == nil)
                            {
                                // make sure the error is as expected
                                XCTAssertNotNil(aspectDefError, @"Expected to recieve an error");
                                XCTAssertTrue(aspectDefError.code == kAlfrescoErrorCodeModelDefinitionNotFound,
                                              @"Expected the error code to be 1301 but was %lu", aspectDefError.code);
                                
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

- (void)disabledtestRetrieveTaskDefinition
{
    // TODO
    
    XCTFail(@"Test not implemented yet: %@", NSStringFromSelector(_cmd));
}

- (void)disabledtestRetrieveDefinitionFromDocument
{
    // TODO
    
    XCTFail(@"Test not implemented yet: %@", NSStringFromSelector(_cmd));
}

- (void)disabledtestRetrieveDefinitionFromFolder
{
    // TODO
    
    XCTFail(@"Test not implemented yet: %@", NSStringFromSelector(_cmd));
}

- (void)disabledtestRetrieveDefinitionFromTask
{
    // TODO
    
    XCTFail(@"Test not implemented yet: %@", NSStringFromSelector(_cmd));
}

@end

/*
  Licensed to the Apache Software Foundation (ASF) under one
  or more contributor license agreements.  See the NOTICE file
  distributed with this work for additional information
  regarding copyright ownership.  The ASF licenses this file
  to you under the Apache License, Version 2.0 (the
  "License"); you may not use this file except in compliance
  with the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an
  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  KIND, either express or implied.  See the License for the
  specific language governing permissions and limitations
  under the License.
 */

#import "CMISObject.h"
#import "CMISConstants.h"
#import "CMISErrors.h"
#import "CMISObjectConverter.h"
#import "CMISStringInOutParameter.h"
#import "CMISSession.h"
#import "CMISRenditionData.h"
#import "CMISRendition.h"
#import "CMISLog.h"


@interface CMISObject ()

@property (nonatomic, strong, readwrite) CMISSession *session;
@property (nonatomic, strong, readwrite) id<CMISBinding> binding;

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *createdBy;
@property (nonatomic, strong, readwrite) NSDate *creationDate;
@property (nonatomic, strong, readwrite) NSString *lastModifiedBy;
@property (nonatomic, strong, readwrite) NSDate *lastModificationDate;
@property (nonatomic, strong, readwrite) NSString *objectType;
@property (nonatomic, strong, readwrite) NSString *changeToken;
@property (nonatomic, strong, readwrite) CMISTypeDefinition *typeDefinition;

@property (nonatomic, strong, readwrite) CMISProperties *properties;
@property (nonatomic, strong, readwrite) CMISAllowableActions *allowableActions;
@property (nonatomic, strong, readwrite) CMISAcl *acl;
@property (nonatomic, strong, readwrite) NSArray *renditions;

@property (nonatomic, strong) NSMutableDictionary *extensionsDict;

// returns a non-nil NSArray
- (NSArray *)nonNilArray:(NSArray *)aArray;
@end

@implementation CMISObject

- (id)initWithObjectData:(CMISObjectData *)objectData session:(CMISSession *)session
{
    self =  [super initWithString:objectData.identifier];
    if (self) {
        self.session = session;
        self.binding = session.binding;

        self.properties = objectData.properties;
        self.name = [[self.properties propertyForId:kCMISPropertyName] firstValue];
        self.createdBy = [[self.properties propertyForId:kCMISPropertyCreatedBy] firstValue];
        self.lastModifiedBy = [[self.properties propertyForId:kCMISPropertyModifiedBy] firstValue];
        self.creationDate = [[self.properties propertyForId:kCMISPropertyCreationDate] firstValue];
        self.lastModificationDate = [[self.properties propertyForId:kCMISPropertyModificationDate] firstValue];
        self.objectType = [[self.properties propertyForId:kCMISPropertyObjectTypeId] firstValue];
        self.changeToken = [[self.properties propertyForId:kCMISPropertyChangeToken] firstValue];

        self.allowableActions = objectData.allowableActions;
        self.acl = objectData.acl;

        // Extract Extensions and store in the extensionsDict
        self.extensionsDict = [[NSMutableDictionary alloc] init];
        [self.extensionsDict setObject:[self nonNilArray:objectData.extensions] forKey:[NSNumber numberWithInteger:CMISExtensionLevelObject]];
        [self.extensionsDict setObject:[self nonNilArray:self.properties.extensions] forKey:[NSNumber numberWithInteger:CMISExtensionLevelProperties]];
        [self.extensionsDict setObject:[self nonNilArray:self.allowableActions.extensions] forKey:[NSNumber numberWithInteger:CMISExtensionLevelAllowableActions]];
        [self.extensionsDict setObject:[self nonNilArray:self.acl.extensions] forKey:[NSNumber numberWithInteger:CMISExtensionLevelAcl]];

        // Renditions must be converted here, because they need access to the session
        if (objectData.renditions != nil) {
            NSMutableArray *renditions = [NSMutableArray array];
            for (CMISRenditionData *renditionData in objectData.renditions) {
                [renditions addObject:[[CMISRendition alloc] initWithRenditionData:renditionData objectId:self.identifier session:session]];
            }
            self.renditions = renditions;
        }
    }
    
    return self;
}


- (void)fetchTypeDefinitionWithCompletionBlock:(void (^)(NSError *error))completionBlock
{
    if (self.typeDefinition) {
        if (completionBlock) {
            completionBlock(nil);
        }
    } else {
        [self.session retrieveTypeDefinition:self.objectType
                             completionBlock:^(CMISTypeDefinition *typeDefinition, NSError *error) {
                                 if (error == nil) {
                                     self.typeDefinition = typeDefinition;
                                 } else {
                                     CMISLogError(@"Error while fetching type definiton for object type %@: %@", self.objectType, error.description);
                                 }
                                 if (completionBlock) {
                                     completionBlock(error);
                                 }
                             }];
    }
}


- (NSArray *)nonNilArray:(NSArray *)aArray
{   // Move to category on NSArray?
    return ((aArray == nil) ? [NSArray array] : aArray);
}

- (void)updateProperties:(NSDictionary *)properties completionBlock:(void (^)(CMISObject *object, NSError *error))completionBlock
{
    // Validate properties param
    if (!properties || properties.count == 0) {
        completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument detailedDescription:@"Properties cannot be nil or empty"]);
        return;
    }

    // Convert properties to an understandable format for the service
    [self.session.objectConverter convertProperties:properties forObjectTypeId:self.objectType completionBlock:^(CMISProperties *convertedProperties, NSError *error) {
        if (convertedProperties) {
            CMISStringInOutParameter *objectIdInOutParam = [CMISStringInOutParameter inOutParameterUsingInParameter:self.identifier];
            CMISStringInOutParameter *changeTokenInOutParam = [CMISStringInOutParameter inOutParameterUsingInParameter:self.changeToken];
            [self.binding.objectService
             updatePropertiesForObject:objectIdInOutParam
             properties:convertedProperties
             changeToken:changeTokenInOutParam
             completionBlock:^(NSError *error) {
                 if (objectIdInOutParam.outParameter) {
                     [self.session retrieveObject:objectIdInOutParam.outParameter
                                  completionBlock:^(CMISObject *object, NSError *error) {
                                      completionBlock(object, error);
                                  }];
                 } else {
                     completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeRuntime]);
                 }
             }];
        } else {
            completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeRuntime]);
        }
    }];
}

- (NSArray *)extensionsForExtensionLevel:(CMISExtensionLevel)extensionLevel
{
    // TODO Need to implement the following extension levels CMISExtensionLevelAcl, CMISExtensionLevelPolicies, CMISExtensionLevelChangeEvent
    
    return [self.extensionsDict objectForKey:[NSNumber numberWithInteger:extensionLevel]];
}

@end

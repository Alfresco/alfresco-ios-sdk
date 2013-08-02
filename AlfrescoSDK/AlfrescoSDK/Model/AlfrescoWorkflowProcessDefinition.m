/*
 ******************************************************************************
 * Copyright (C) 2005-2013 Alfresco Software Limited.
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
 *****************************************************************************
 */

/** The AlfrescoWorkflowProcessDefinition model object
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AlfrescoWorkflowProcessDefinition.h"
#import "AlfrescoInternalConstants.h"

@interface AlfrescoWorkflowProcessDefinition ()

@property (nonatomic, strong, readwrite) NSString *identifier;
@property (nonatomic, strong, readwrite) NSString *category;
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *startFormKey;
@property (nonatomic, strong, readwrite) NSString *depolymentIdentifier;
@property (nonatomic, assign, readwrite) BOOL graphicNotationDefined;
@property (nonatomic, strong, readwrite) NSString *key;
@property (nonatomic, strong, readwrite) NSNumber *version;

@end

@implementation AlfrescoWorkflowProcessDefinition

- (id)initWithProperties:(NSDictionary *)properties
{
    self = [super init];
    if (self)
    {
        [self setupProperties:properties];
    }
    return self;
}

#pragma mark - Private Functions

- (void)setupProperties:(NSDictionary *)propterties
{
    NSDictionary *entry = [propterties objectForKey:kAlfrescoCloudJSONEntry];
    self.identifier = [entry objectForKey:kAlfrescoJSONIdentifier];
    self.category = [entry objectForKey:kAlfrescoJSONCategory];
    self.name = [entry objectForKey:kAlfrescoJSONName];
    self.startFormKey = [entry objectForKey:kAlfrescoJSONStartFormResourceKey];
    self.depolymentIdentifier = [entry objectForKey:kAlfrescoJSONDeploymentID];
    self.graphicNotationDefined = [[entry objectForKey:kAlfrescoJSONGraphicNotationDefined] boolValue];
    self.key = [entry objectForKey:kAlfrescoJSONKey];
    self.version = [entry objectForKey:kAlfrescoJSONVersion];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
//    [aCoder encodeInteger:kTagModelVersion forKey:NSStringFromClass([self class])];
//    [aCoder encodeObject:self.value forKey:kAlfrescoJSONTag];
//    [aCoder encodeObject:self.identifier forKey:kAlfrescoJSONIdentifier];
}
//
- (id)initWithCoder:(NSCoder *)aDecoder
{
//    self = [super init];
//    if (nil != self)
//    {
//        //uncomment this line if you need to check the model version
//        //        NSInteger version = [aDecoder decodeIntForKey:NSStringFromClass([self class])];
//        self.value = [aDecoder decodeObjectForKey:kAlfrescoJSONTag];
//        self.identifier = [aDecoder decodeObjectForKey:kAlfrescoJSONIdentifier];
//    }
    return self;
}

@end

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

/** The AlfrescoWorkflowVariable model object
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AlfrescoWorkflowVariable.h"
#import "AlfrescoInternalConstants.h"

static NSInteger kWorkflowVariableModelVersion = 1;

@interface AlfrescoWorkflowVariable ()

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *type;
@property (nonatomic, strong, readwrite) id value;

@end

@implementation AlfrescoWorkflowVariable

- (instancetype)initWithProperties:(NSDictionary *)properties
{
    self = [super init];
    if (self)
    {
        [self setupProperties:properties];
    }
    return self;
}

#pragma mark - Priavte Functions

- (void)setupProperties:(NSDictionary *)properties
{
    self.name = [properties valueForKey:kAlfrescoPublicJSONVariableName];
    self.type = [properties valueForKey:kAlfrescoPublicJSONVariableType];
    self.value = [properties valueForKey:kAlfrescoPublicJSONVariableValue];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:kWorkflowVariableModelVersion forKey:NSStringFromClass([self class])];
    [aCoder encodeObject:self.name forKey:kAlfrescoPublicJSONIdentifier];
    [aCoder encodeObject:self.type forKey:kAlfrescoPublicJSONVariableType];
    [aCoder encodeObject:self.value forKey:kAlfrescoPublicJSONVariableValue];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        //        NSInteger version = [aDecoder decodeIntegerForKey:NSStringFromClass([self class])];
        self.name = [aDecoder decodeObjectForKey:kAlfrescoPublicJSONIdentifier];
        self.type = [aDecoder decodeObjectForKey:kAlfrescoPublicJSONVariableType];
        self.value = [aDecoder decodeObjectForKey:kAlfrescoPublicJSONVariableValue];
    }
    return self;
}

@end

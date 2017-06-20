/*******************************************************************************
 * Copyright (C) 2005-2017 Alfresco Software Limited.
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

#import "AlfrescoSAMLInfo.h"
#import "AlfrescoInternalConstants.h"

NSString * const kAlfrescoSamlEnabledKey = @"isSamlEnabled";
NSString * const kAlfrescoSamlEnforcedKey = @"isSamlEnforced";
NSString * const kAlfrescoIdpDescriptionKey = @"idpDescription";
NSString * const kAlfrescoTenantDomainKey = @"tenantDomain";

@interface AlfrescoSAMLInfo ()

@property (nonatomic, assign, readwrite, getter=isSamlEnabled) BOOL samlEnabled;
@property (nonatomic, assign, readwrite, getter=isSamlEnforced) BOOL samlEnforced;
@property (nonatomic, strong, readwrite, getter=getIdpDescription) NSString *idpDescription;
@property (nonatomic, strong, readwrite, getter=getTenantDomain) NSString *tenantDomain;

@end

@implementation AlfrescoSAMLInfo

- (instancetype)initWithSamlEnabled:(BOOL)samlEnabled samlEnforced:(BOOL)samlEnforced idpDescription:(NSString *)idpDescription tenantDomain:(NSString *)tenantDomain
{
    if (self = [super init])
    {
        self.samlEnabled = samlEnabled;
        self.samlEnforced = samlEnforced;
        self.idpDescription = idpDescription;
        self.tenantDomain = tenantDomain;
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        NSDictionary *entryDictionary = dictionary[kAlfrescoPublicAPIJSONEntry];
        
        if (entryDictionary)
        {
            self.samlEnabled = entryDictionary[kAlfrescoSamlEnabledKey] ? [entryDictionary[kAlfrescoSamlEnabledKey] boolValue] : NO;
            self.samlEnforced = entryDictionary[kAlfrescoSamlEnforcedKey] ? [entryDictionary[kAlfrescoSamlEnforcedKey] boolValue] : NO;
            self.idpDescription = entryDictionary[kAlfrescoIdpDescriptionKey];
            self.tenantDomain = entryDictionary[kAlfrescoTenantDomainKey];
        }
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.samlEnabled = [[aDecoder decodeObjectForKey:kAlfrescoSamlEnabledKey] boolValue];
        self.samlEnforced = [[aDecoder decodeObjectForKey:kAlfrescoSamlEnforcedKey] boolValue];
        self.idpDescription = [aDecoder decodeObjectForKey:kAlfrescoIdpDescriptionKey];
        self.tenantDomain = [aDecoder decodeObjectForKey:kAlfrescoTenantDomainKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(self.samlEnabled) forKey:kAlfrescoSamlEnabledKey];
    [aCoder encodeObject:@(self.samlEnforced) forKey:kAlfrescoSamlEnforcedKey];

    if (self.idpDescription)
    {
        [aCoder encodeObject:self.idpDescription forKey:kAlfrescoIdpDescriptionKey];
    }
    
    if (self.tenantDomain)
    {
        [aCoder encodeObject:self.tenantDomain forKey:kAlfrescoTenantDomainKey];
    }
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString string];
    
    [description appendFormat:@"\nsamlEnabled:%d", self.samlEnabled];
    [description appendFormat:@"\nsamlEnforced:%d", self.samlEnforced];
    [description appendFormat:@"\nidpDescription:%@", self.idpDescription];
    [description appendFormat:@"\ntenantDomain:%@", self.tenantDomain];
    
    return description;
}

@end

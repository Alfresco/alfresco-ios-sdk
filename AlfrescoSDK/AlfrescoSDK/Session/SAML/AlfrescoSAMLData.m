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

#import "AlfrescoSAMLData.h"

@interface AlfrescoSAMLData ()

@property (nonatomic, assign, readwrite, getter=isSamlEnabled) BOOL samlEnabled;
@property (nonatomic, assign, readwrite, getter=isSamlEnforced) BOOL samlEnforced;
@property (nonatomic, strong, readwrite, getter=getIdpDescription) NSString *idpDescription;
@property (nonatomic, strong, readwrite, getter=getTenantDomain) NSString *tenantDomain;
@property (nonatomic, strong, readwrite, getter=getTicket) NSString *ticket;
@property (nonatomic, strong, readwrite, getter=getUserID) NSString *userID;

@end

@implementation AlfrescoSAMLData

- (instancetype)initWithSamlInfo:(AlfrescoSAMLInfo *)samlInfo samlTicket:(AlfrescoSAMLTicket *)samlTicket
{
    if (self = [super init])
    {
        self.samlInfo = samlInfo;
        self.samlTicket = samlTicket;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.samlInfo = [aDecoder decodeObjectForKey:@"samlInfo"];
        self.samlTicket = [aDecoder decodeObjectForKey:@"samlTicket"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if (self.samlInfo)
    {
        [aCoder encodeObject:self.samlInfo forKey:@"samlInfo"];
    }
    
    if (self.samlTicket)
    {
        [aCoder encodeObject:self.samlTicket forKey:@"samlTicket"];
    }
}

- (BOOL)isSamlEnabled
{
    return self.samlInfo == nil ? NO : self.samlInfo.samlEnabled;
}

- (BOOL)isSamlEnforced
{
    return self.samlInfo == nil ? NO : self.samlInfo.samlEnforced;
}

- (NSString *)getIdpDescription
{
    return self.samlInfo == nil ? nil : self.samlInfo.idpDescription;
}

- (NSString *)getTenantDomain
{
    return self.samlInfo == nil ? nil : self.samlInfo.tenantDomain;
}

- (NSString *)getTicket
{
    return self.samlTicket == nil ? nil : [self.samlTicket getTicket];
}

- (NSString *)getUserID
{
    return self.samlTicket == nil ? nil : [self.samlTicket getUserID];
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString string];
    
    [description appendString:self.samlInfo.description];
    [description appendString:self.samlTicket.description];
    
    return description;
}

@end

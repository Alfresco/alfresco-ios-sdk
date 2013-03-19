/*******************************************************************************
 * Copyright (C) 2005-2012 Alfresco Software Limited.
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

#import "AlfrescoPerson.h"
#import "AlfrescoInternalConstants.h"
@interface AlfrescoPerson ()
@property (nonatomic, strong, readwrite) NSString *identifier;
@property (nonatomic, strong, readwrite) NSString *firstName;
@property (nonatomic, strong, readwrite) NSString *lastName;
@property (nonatomic, strong, readwrite) NSString *fullName;
@property (nonatomic, strong, readwrite) NSString *avatarIdentifier;
@property (nonatomic, assign, readwrite) NSUInteger modelClassVersion;
- (void)setOnPremiseProperties:(NSDictionary *)properties;
- (void)setCloudProperties:(NSDictionary *)properties;
@end

@implementation AlfrescoPerson


///Cloud
/*
 AlfrescoPerson *alfPerson = [[AlfrescoPerson alloc] init];
 alfPerson.identifier = [personDict valueForKey:kAlfrescoJSONIdentifier];
 alfPerson.firstName = [personDict valueForKey:kAlfrescoJSONFirstName];
 alfPerson.lastName = [personDict valueForKey:kAlfrescoJSONLastName];
 if (alfPerson.lastName != nil && alfPerson.lastName.length > 0)
 {
 if (alfPerson.firstName != nil && alfPerson.firstName.length > 0)
 {
 alfPerson.fullName = [NSString stringWithFormat:@"%@ %@", alfPerson.firstName, alfPerson.lastName];
 }
 else
 {
 alfPerson.fullName = alfPerson.lastName;
 }
 }
 else if (alfPerson.firstName != nil && alfPerson.firstName.length > 0)
 {
 alfPerson.fullName = alfPerson.firstName;
 }
 else
 {
 alfPerson.fullName = alfPerson.identifier;
 }
 alfPerson.avatarIdentifier = [personDict valueForKey:kAlfrescoJSONAvatarId];
 */

///OnPremise
/*
 - (AlfrescoPerson *)personFromJSON:(NSDictionary *)personDict
 {
 AlfrescoPerson *alfPerson = [[AlfrescoPerson alloc] init];
 alfPerson.identifier = [personDict valueForKey:kAlfrescoJSONUserName];
 alfPerson.firstName = [personDict valueForKey:kAlfrescoJSONFirstName];
 alfPerson.lastName = [personDict valueForKey:kAlfrescoJSONLastName];
 if (alfPerson.lastName != nil && alfPerson.lastName.length > 0)
 {
 if (alfPerson.firstName != nil && alfPerson.firstName.length > 0)
 {
 alfPerson.fullName = [NSString stringWithFormat:@"%@ %@", alfPerson.firstName, alfPerson.lastName];
 }
 else
 {
 alfPerson.fullName = alfPerson.lastName;
 }
 }
 else if (alfPerson.firstName != nil && alfPerson.firstName.length > 0)
 {
 alfPerson.fullName = alfPerson.firstName;
 }
 else
 {
 alfPerson.fullName = alfPerson.identifier;
 }
 alfPerson.avatarIdentifier = [personDict valueForKey:kAlfrescoJSONAvatar];
 return alfPerson;
 }
 */

- (id)initWithProperties:(NSDictionary *)properties
{
    self = [super init];
    if (nil != self)
    {
        self.modelClassVersion = kAlfrescoPersonModelVersion;
        [self setOnPremiseProperties:properties];
        [self setCloudProperties:properties];
        
        if ([[properties allKeys] containsObject:kAlfrescoJSONFirstName])
        {
            self.firstName = [properties valueForKey:kAlfrescoJSONFirstName];
        }
        if ([[properties allKeys] containsObject:kAlfrescoJSONLastName])
        {
            self.lastName = [properties valueForKey:kAlfrescoJSONLastName];
        }
        if (self.lastName != nil && self.lastName.length > 0)
        {
            if (self.firstName != nil && self.firstName.length > 0)
            {
                self.fullName = [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
            }
            else
            {
                self.fullName = self.lastName;
            }
        }
        else if (self.firstName != nil && self.firstName.length > 0)
        {
            self.fullName = self.firstName;
        }
        else
        {
            self.fullName = self.identifier;
        }
    }
    return self;
}

- (void)setOnPremiseProperties:(NSDictionary *)properties
{
    if ([[properties allKeys] containsObject:kAlfrescoJSONUserName])
    {
        self.identifier = [properties valueForKey:kAlfrescoJSONUserName];
    }
    if ([[properties allKeys] containsObject:kAlfrescoJSONAvatar])
    {
        self.avatarIdentifier = [properties valueForKey:kAlfrescoJSONAvatar];
    }
    
}

- (void)setCloudProperties:(NSDictionary *)properties
{
    if ([[properties allKeys] containsObject:kAlfrescoJSONIdentifier])
    {
        self.identifier = [properties valueForKey:kAlfrescoJSONIdentifier];
    }
    if ([[properties allKeys] containsObject:kAlfrescoJSONAvatarId])
    {
        id avatarObj = [properties valueForKey:kAlfrescoJSONAvatarId];
        if ([avatarObj isKindOfClass:[NSString class]])
        {
            self.avatarIdentifier = [properties valueForKey:kAlfrescoJSONAvatarId];
        }
        else if ([avatarObj isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *avatarDict = (NSDictionary *)avatarObj;
            if ([[avatarDict allKeys] containsObject:kAlfrescoJSONIdentifier])
            {
                self.avatarIdentifier = [avatarDict valueForKey:kAlfrescoJSONIdentifier];
            }
            
        }
    }
    
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.avatarIdentifier forKey:kAlfrescoJSONAvatarId];
    [aCoder encodeObject:self.firstName forKey:kAlfrescoJSONFirstName];
    [aCoder encodeObject:self.lastName forKey:kAlfrescoJSONLastName];
    [aCoder encodeObject:self.fullName forKey:@"fullName"];
    [aCoder encodeObject:self.identifier forKey:kAlfrescoJSONIdentifier];
    [aCoder encodeInteger:self.modelClassVersion forKey:kAlfrescoModelClassVersion];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (nil != self)
    {
        self.avatarIdentifier = [aDecoder decodeObjectForKey:kAlfrescoJSONAvatarId];
        self.firstName = [aDecoder decodeObjectForKey:kAlfrescoJSONFirstName];
        self.lastName = [aDecoder decodeObjectForKey:kAlfrescoJSONLastName];
        self.fullName = [aDecoder decodeObjectForKey:@"fullName"];
        self.identifier = [aDecoder decodeObjectForKey:kAlfrescoJSONIdentifier];
        self.modelClassVersion = [aDecoder decodeIntForKey:kAlfrescoModelClassVersion];
    }
    return self;
}


@end

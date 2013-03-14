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

#import "AlfrescoSite.h"
#import "AlfrescoInternalConstants.h"

@interface AlfrescoSite ()
@property (nonatomic, strong, readwrite) NSString *shortName;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSString *summary;
@property (nonatomic, assign, readwrite) AlfrescoSiteVisibility visibility;
@property (nonatomic, strong, readwrite) NSString *identifier;
@property (nonatomic, strong, readwrite) NSString *GUID;
@property (nonatomic, assign, readwrite) BOOL isMember;
@property (nonatomic, assign, readwrite) BOOL isPendingMember;
@property (nonatomic, assign, readwrite) BOOL isFavorite;
- (void)setUpOnPremiseProperties:(NSDictionary *)properties keys:(NSArray *)keys;
- (void)setUpCloudProperties:(NSDictionary *)properties keys:(NSArray *)keys;
@end

@implementation AlfrescoSite


- (id)initWithProperties:(NSDictionary *)properties
{
    self = [super init];
    if (nil != self)
    {
        self.isFavorite = NO;
        self.isMember = NO;
        self.isPendingMember = NO;

        NSArray *allKeys = [properties allKeys];
        [self setUpOnPremiseProperties:properties keys:allKeys];
        [self setUpCloudProperties:properties keys:allKeys];
        if ([allKeys containsObject:kAlfrescoJSONDescription])
        {
            self.summary = [properties valueForKey:kAlfrescoJSONDescription];
        }
        if ([allKeys containsObject:kAlfrescoJSONTitle])
        {
            self.title = [properties valueForKey:kAlfrescoJSONTitle];
        }
        if ([allKeys containsObject:kAlfrescoJSONVisibility])
        {
            NSString *visibility = [properties valueForKey:kAlfrescoJSONVisibility];
            if ([visibility isEqualToString:kAlfrescoJSONVisibilityPUBLIC])
            {
                self.visibility = AlfrescoSiteVisibilityPublic;
            }
            else if ([visibility isEqualToString:kAlfrescoJSONVisibilityPRIVATE])
            {
                self.visibility = AlfrescoSiteVisibilityPrivate;
            }
            else if ([visibility isEqualToString:kAlfrescoJSONVisibilityMODERATED])
            {
                self.visibility = AlfrescoSiteVisibilityModerated;
            }
            
        }
        if ([allKeys containsObject:kAlfrescoSiteIsFavorite])
        {
            NSNumber *value = [properties valueForKey:kAlfrescoSiteIsFavorite];
            self.isFavorite = [value boolValue];
        }
        if ([allKeys containsObject:kAlfrescoSiteIsMember])
        {
            NSNumber *value = [properties valueForKey:kAlfrescoSiteIsMember];
            self.isMember = [value boolValue];
        }
        if ([allKeys containsObject:kAlfrescoSiteIsPendingMember])
        {
            NSNumber *value = [properties valueForKey:kAlfrescoSiteIsPendingMember];
            self.isPendingMember = [value boolValue];
        }
        if ([allKeys containsObject:kAlfrescoJSONGUID])
        {
            self.GUID = [properties valueForKey:kAlfrescoJSONGUID];
        }
        
    }
    return self;
}

- (void)setUpOnPremiseProperties:(NSDictionary *)properties keys:(NSArray *)keys
{
    if ([keys containsObject:kAlfrescoJSONShortname])
    {
        self.shortName = [properties valueForKey:kAlfrescoJSONShortname];
        self.identifier = self.shortName;
    }
}

- (void)setUpCloudProperties:(NSDictionary *)properties keys:(NSArray *)keys
{
    if ([keys containsObject:kAlfrescoJSONIdentifier])
    {
        id siteObj = [properties valueForKey:kAlfrescoJSONIdentifier];
        if ([siteObj isKindOfClass:[NSString class]])
        {
            self.shortName = [properties valueForKey:kAlfrescoJSONIdentifier];
        }
        else if([siteObj isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *siteDict = (NSDictionary *)siteObj;
            if ([[siteDict allKeys] containsObject:kAlfrescoJSONIdentifier])
            {
                self.shortName = [siteDict valueForKey:kAlfrescoJSONIdentifier];
                self.identifier = self.shortName;
            }
            
        }
    }
}

#pragma NSCoding methods

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if (nil != self.summary)
    {
        [aCoder encodeObject:self.summary forKey:kAlfrescoJSONDescription];
    }
    if (nil != self.title)
    {
        [aCoder encodeObject:self.title forKey:kAlfrescoJSONTitle];
    }
    [aCoder encodeInt:self.visibility forKey:kAlfrescoJSONVisibility];
    if (nil != self.shortName)
    {
        [aCoder encodeObject:self.shortName forKey:kAlfrescoJSONShortname];
    }
    if (nil != self.GUID)
    {
        [aCoder encodeObject:self.GUID forKey:kAlfrescoJSONGUID];
    }
    [aCoder encodeBool:self.isFavorite forKey:kAlfrescoSiteIsFavorite];
    [aCoder encodeBool:self.isMember forKey:kAlfrescoSiteIsMember];
    [aCoder encodeBool:self.isPendingMember forKey:kAlfrescoSiteIsPendingMember];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSString *summary       = [aDecoder decodeObjectForKey:kAlfrescoJSONDescription];
    NSString *title         = [aDecoder decodeObjectForKey:kAlfrescoJSONTitle];
    int visibility          = [aDecoder decodeIntForKey:kAlfrescoJSONVisibility];
    BOOL isFavorite         = [aDecoder decodeBoolForKey:kAlfrescoSiteIsFavorite];
    BOOL isMember           = [aDecoder decodeBoolForKey:kAlfrescoSiteIsMember];
    BOOL isPendingMember    = [aDecoder decodeBoolForKey:kAlfrescoSiteIsPendingMember];
    NSString *shortName     = [aDecoder decodeObjectForKey:kAlfrescoJSONShortname];
    NSString *guid          = [aDecoder decodeObjectForKey:kAlfrescoJSONGUID];
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    if (summary)
    {
        [properties setValue:summary forKey:kAlfrescoJSONDescription];
    }
    if (title)
    {
        [properties setValue:title forKey:kAlfrescoJSONTitle];
    }
    switch (visibility)
    {
        case AlfrescoSiteVisibilityPublic:
            [properties setValue:kAlfrescoJSONVisibilityPUBLIC forKey:kAlfrescoJSONVisibility];
            break;
        case AlfrescoSiteVisibilityPrivate:
            [properties setValue:kAlfrescoJSONVisibilityPRIVATE forKey:kAlfrescoJSONVisibility];
            break;
        case AlfrescoSiteVisibilityModerated:
            [properties setValue:kAlfrescoJSONVisibilityMODERATED forKey:kAlfrescoJSONVisibility];
            break;
    }
    if (shortName)
    {
        [properties setValue:shortName forKey:kAlfrescoJSONShortname];
    }
    if (guid)
    {
        [properties setValue:guid forKey:kAlfrescoJSONGUID];
    }
    [properties setValue:[NSNumber numberWithBool:isFavorite] forKey:kAlfrescoSiteIsFavorite];
    [properties setValue:[NSNumber numberWithBool:isMember] forKey:kAlfrescoSiteIsMember];
    [properties setValue:[NSNumber numberWithBool:isPendingMember] forKey:kAlfrescoSiteIsPendingMember];
    
    return [self initWithProperties:properties];
}
@end

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
- (void)setUpOnPremiseProperties:(NSDictionary *)properties;
- (void)setUpCloudProperties:(NSDictionary *)properties;
@end

@implementation AlfrescoSite



- (id)initWithProperties:(NSDictionary *)properties
{
    self = [super init];
    if (nil != self)
    {
        [self setUpOnPremiseProperties:properties];
        [self setUpCloudProperties:properties];
        if ([[properties allKeys] containsObject:kAlfrescoJSONDescription])
        {
            self.summary = [properties valueForKey:kAlfrescoJSONDescription];
        }
        if ([[properties allKeys] containsObject:kAlfrescoJSONTitle])
        {
            self.title = [properties valueForKey:kAlfrescoJSONTitle];            
        }
        if ([[properties allKeys] containsObject:kAlfrescoJSONVisibility])
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
    }
    return self;
}

- (void)setUpOnPremiseProperties:(NSDictionary *)properties
{
    if ([[properties allKeys] containsObject:kAlfrescoJSONShortname])
    {
        self.shortName = [properties valueForKey:kAlfrescoJSONShortname];
    }    
}

- (void)setUpCloudProperties:(NSDictionary *)properties
{
    if ([[properties allKeys] containsObject:kAlfrescoJSONIdentifier])
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
            }
            
        }
    }
}

@end

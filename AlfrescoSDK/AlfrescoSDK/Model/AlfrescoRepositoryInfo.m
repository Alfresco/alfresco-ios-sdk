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

#import "AlfrescoRepositoryInfo.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoRepositoryCapabilities.h"

@interface AlfrescoRepositoryInfo ()
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *identifier;
@property (nonatomic, strong, readwrite) NSString *summary;
@property (nonatomic, strong, readwrite) NSString *edition;
@property (nonatomic, strong, readwrite) NSNumber *majorVersion;
@property (nonatomic, strong, readwrite) NSNumber *minorVersion;
@property (nonatomic, strong, readwrite) NSNumber *maintenanceVersion;
@property (nonatomic, strong, readwrite) NSString *buildNumber;
@property (nonatomic, strong, readwrite) NSString *version;
@property (nonatomic, strong, readwrite) AlfrescoRepositoryCapabilities *capabilities;

@end

@implementation AlfrescoRepositoryInfo


- (id)initWithProperties:(NSDictionary *)properties
{
    self = [super init];
    if (self) 
    {
        self.name               = (NSString *)[properties objectForKey:kAlfrescoRepositoryName];
        self.identifier         = (NSString *)[properties objectForKey:kAlfrescoRepositoryIdentifier];
        self.summary            = (NSString *)[properties objectForKey:kAlfrescoRepositorySummary];
        self.edition            = (NSString *)[properties objectForKey:kAlfrescoRepositoryEdition];
        self.majorVersion       = (NSNumber *)[properties objectForKey:kAlfrescoRepositoryMajorVersion];
        self.minorVersion       = (NSNumber *)[properties objectForKey:kAlfrescoRepositoryMinorVersion];
        self.maintenanceVersion = (NSNumber *)[properties objectForKey:kAlfrescoRepositoryMaintenanceVersion];
        self.buildNumber        = (NSString *)[properties objectForKey:kAlfrescoRepositoryBuildNumber];
        self.version            = (NSString *)[properties objectForKey:kAlfrescoRepositoryVersion];
        self.capabilities       = (AlfrescoRepositoryCapabilities *)[properties objectForKey:kAlfrescoRepositoryCapabilities];
    }
    return self;
}

@end

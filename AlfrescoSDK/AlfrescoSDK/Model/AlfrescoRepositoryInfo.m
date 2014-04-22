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

static NSInteger kRepositoryInfoModelVersion = 1;

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
        self.name               = (NSString *)properties[kAlfrescoRepositoryName];
        self.identifier         = (NSString *)properties[kAlfrescoRepositoryIdentifier];
        self.summary            = (NSString *)properties[kAlfrescoRepositorySummary];
        self.edition            = (NSString *)properties[kAlfrescoRepositoryEdition];
        self.majorVersion       = (NSNumber *)properties[kAlfrescoRepositoryMajorVersion];
        self.minorVersion       = (NSNumber *)properties[kAlfrescoRepositoryMinorVersion];
        self.maintenanceVersion = (NSNumber *)properties[kAlfrescoRepositoryMaintenanceVersion];
        self.buildNumber        = (NSString *)properties[kAlfrescoRepositoryBuildNumber];
        self.version            = (NSString *)properties[kAlfrescoRepositoryVersion];
        self.capabilities       = (AlfrescoRepositoryCapabilities *)properties[kAlfrescoRepositoryCapabilities];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:kRepositoryInfoModelVersion forKey:@"AlfrescoRepositoryInfo"];
    [aCoder encodeObject:self.name forKey:kAlfrescoRepositoryName];
    [aCoder encodeObject:self.identifier forKey:kAlfrescoRepositoryIdentifier];
    [aCoder encodeObject:self.summary forKey:kAlfrescoRepositorySummary];
    [aCoder encodeObject:self.edition forKey:kAlfrescoRepositoryEdition];
    [aCoder encodeObject:self.majorVersion forKey:kAlfrescoRepositoryMajorVersion];
    [aCoder encodeObject:self.minorVersion forKey:kAlfrescoRepositoryMinorVersion];
    [aCoder encodeObject:self.maintenanceVersion forKey:kAlfrescoRepositoryMaintenanceVersion];
    [aCoder encodeObject:self.buildNumber forKey:kAlfrescoRepositoryBuildNumber];
    [aCoder encodeObject:self.version forKey:kAlfrescoRepositoryVersion];
    [aCoder encodeObject:self.capabilities forKey:kAlfrescoRepositoryCapabilities];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(nil != self)
    {
        //uncomment this line if you need to check the model version
//        NSInteger version = [aDecoder decodeIntForKey:@"AlfrescoRepositoryInfo"];
        self.name = [aDecoder decodeObjectForKey:kAlfrescoRepositoryName];
        self.identifier = [aDecoder decodeObjectForKey:kAlfrescoRepositoryIdentifier];
        self.summary = [aDecoder decodeObjectForKey:kAlfrescoRepositorySummary];
        self.edition = [aDecoder decodeObjectForKey:kAlfrescoRepositoryEdition];
        self.majorVersion = [aDecoder decodeObjectForKey:kAlfrescoRepositoryMajorVersion];
        self.minorVersion = [aDecoder decodeObjectForKey:kAlfrescoRepositoryMinorVersion];
        self.maintenanceVersion = [aDecoder decodeObjectForKey:kAlfrescoRepositoryMaintenanceVersion];
        self.buildNumber = [aDecoder decodeObjectForKey:kAlfrescoRepositoryBuildNumber];
        self.version = [aDecoder decodeObjectForKey:kAlfrescoRepositoryVersion];
        self.capabilities = [aDecoder decodeObjectForKey:kAlfrescoRepositoryCapabilities];
    }
    return self;
}


@end

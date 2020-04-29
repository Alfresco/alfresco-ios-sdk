/*
 ******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
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

#import "AlfrescoVersionInfo.h"
#import "AlfrescoErrors.h"

@interface AlfrescoVersionInfo ()
@property (nonatomic, strong, readwrite) NSString *edition;
@property (nonatomic, strong, readwrite) NSNumber *majorVersion;
@property (nonatomic, strong, readwrite) NSNumber *minorVersion;
@property (nonatomic, strong, readwrite) NSNumber *maintenanceVersion;
@property (nonatomic, strong, readwrite) NSString *buildNumber;
@end

@implementation AlfrescoVersionInfo

- (instancetype)initWithVersionString:(NSString*)version edition:(NSString *)edition
{
    if (self = [super init])
    {
        [AlfrescoErrors assertStringArgumentNotNilOrEmpty:version argumentName:@"version"];
        [AlfrescoErrors assertStringArgumentNotNilOrEmpty:edition argumentName:@"edition"];
        
        self.edition = edition;
        
        // parse the version string into it's main parts
        NSArray *versionAndBuildComponents = [version componentsSeparatedByString:@"("];
        
        // extract version numbers
        if (versionAndBuildComponents.count > 0)
        {
            NSString *rawVersionNumber = versionAndBuildComponents.firstObject;
            NSArray *versionNumberComponents = [[rawVersionNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                                                componentsSeparatedByString:@"."];
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            self.majorVersion = [formatter numberFromString:versionNumberComponents.firstObject];
            if (versionNumberComponents.count > 1)
            {
                self.minorVersion = [formatter numberFromString:versionNumberComponents[1]];
            }
            if (versionNumberComponents.count > 2)
            {
                self.maintenanceVersion = [formatter numberFromString:versionNumberComponents[2]];
            }
            
            // make sure we have default values
            if (self.minorVersion == nil)
            {
                self.minorVersion = @0;
            }
            if (self.maintenanceVersion == nil)
            {
                self.maintenanceVersion = @0;
            }
        }
        
        // extract build number
        if (versionAndBuildComponents.count > 1)
        {
            NSString *rawBuildNumber = versionAndBuildComponents[1];
            
            // replace the trailing parentheses
            self.buildNumber = [rawBuildNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
        }
    }
    
    return self;
}

@end

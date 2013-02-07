/*
 ******************************************************************************
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
 *****************************************************************************
 */

#import "AlfrescoCustomClassParameters.h"

@implementation AlfrescoCustomClassParameters

@synthesize customClassDictionary = _customClassDictionary;
@synthesize customClassesSet = _customClassesSet;

+ (AlfrescoCustomClassParameters *)sharedInstance
{
    static AlfrescoCustomClassParameters *sharedClassParameters;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClassParameters = [[self alloc] init];
    });
    return sharedClassParameters;
}

- (void)setCustomClassDictionary:(NSDictionary *)customClassDictionary
{
    // stop the class dictionary to be set more than once
    if (self.customClassDictionary) {
        return;
    }
    _customClassDictionary = customClassDictionary;
    _customClassesSet = YES;
}

@end

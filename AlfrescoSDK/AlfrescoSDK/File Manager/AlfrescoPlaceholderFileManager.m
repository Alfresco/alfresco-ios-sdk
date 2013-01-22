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

#import "AlfrescoPlaceholderFileManager.h"
#import "AlfrescoConstants.h"
#import "AlfrescoNSFileManager.h"
#import "AlfrescoGDFileManager.h"

@implementation AlfrescoPlaceholderFileManager

- (id)init
{
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *customFileManagerClassString = [infoPlist objectForKey:kAlfrescoFileManagerClass];
    if (customFileManagerClassString)
    {
        Class customFileManagerClass = NSClassFromString((NSString *)customFileManagerClassString);
        if ([customFileManagerClass isSubclassOfClass:[AlfrescoFileManager class]])
        {
            return (id)[[AlfrescoGDFileManager alloc] init];
        }
        else
        {
            // throw exception?
            @throw ([NSException exceptionWithName:@"Class provided should extend AlfrescoFileManager"
                                            reason:@"The custom file manager class provided should extend AlfrescoFileManager"
                                          userInfo:nil]);
        }
    }
    return (id)[[AlfrescoNSFileManager alloc] init];
}

@end

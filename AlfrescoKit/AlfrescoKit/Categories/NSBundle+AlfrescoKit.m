/*
 ******************************************************************************
 * Copyright (C) 2005-2015 Alfresco Software Limited.
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

#import "NSBundle+AlfrescoKit.h"
#import <objc/runtime.h>
#import "AKConstants.h"

@implementation NSBundle (AlfrescoKit)

+ (void)load
{
    Method originalMainBundleMethod = class_getClassMethod([self class], @selector(mainBundle));
    Method swizzledMainBundleMethod = class_getClassMethod([self class], @selector(mainBundle_swizzled));
    
    method_exchangeImplementations(originalMainBundleMethod, swizzledMainBundleMethod);
}

+ (NSBundle *)mainBundle_swizzled
{
    return [NSBundle bundleWithURL:[[NSBundle mainBundle_swizzled] URLForResource:kAlfrescoKitBundleName withExtension:@"bundle"]];
}

@end

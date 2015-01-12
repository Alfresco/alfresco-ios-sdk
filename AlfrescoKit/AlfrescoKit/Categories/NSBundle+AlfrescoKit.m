//
//  NSBundle+AlfrescoKit.m
//  AlfrescoKit
//
//  Created by Tauseef Mughal on 08/01/2015.
//  Copyright (c) 2015 Alfresco. All rights reserved.
//

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

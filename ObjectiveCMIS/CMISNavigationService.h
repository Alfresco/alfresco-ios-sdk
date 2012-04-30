//
//  CMISNavigationService.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 20/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMISFolder;

@protocol CMISNavigationService <NSObject>

// Retrieves the children for the given object identifier.
- (NSArray *)retrieveChildren:(NSString *)objectId error:(NSError **)error;

@end

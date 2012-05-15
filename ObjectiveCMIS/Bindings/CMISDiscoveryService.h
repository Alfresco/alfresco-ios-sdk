//
//  CMISDiscoveryService.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 20/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMISObjectList;

@protocol CMISDiscoveryService <NSObject>

/**
* (optional) Integer maxItems: This is the maximum number of items to return in a response.
*                              The repository MUST NOT exceed this maximum. Default is repository-specific.
(optional) Integer skipCount: This is the number of potential results that the repository MUST skip/page over
                              before returning any results. Defaults to 0.
*/
// TODO: add all params which are required by spec
- (CMISObjectList *)query:(NSString *)statement searchAllVersions:(BOOL)searchAllVersions maxItems:(NSNumber *)maxItems skipCount:(NSNumber *)skipCount error:(NSError * *)error;

@end

//
//  CMISVersioningService.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 20/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISEnums.h"

@class CMISCollection;
@class CMISObject;
@class CMISObjectData;

@protocol CMISVersioningService <NSObject>

/**
 * Get a the latest Document object in the Version Series.
 */
- (CMISObjectData *)retrieveObjectOfLatestVersion:(NSString *)objectId
                                            major:(BOOL)major
                                           filter:(NSString *)filter
                             includeRelationShips:(CMISIncludeRelationship)includeRelationships
                                 includePolicyIds:(BOOL)includePolicyIds
                                  renditionFilter:(NSString *)renditionFilter
                                       includeACL:(BOOL)includeACL
                          includeAllowableActions:(BOOL)includeAllowableActions
                                            error:(NSError **)error;

/*
 * Returns the list of all Document Object in the given version series, sorted by creationDate descending (ie youngest first)
 */
- (NSArray *)retrieveAllVersions:(NSString *)objectId
                          filter:(NSString *)filter
         includeAllowableActions:(BOOL)includeAllowableActions
                           error:(NSError * *)error;

@end

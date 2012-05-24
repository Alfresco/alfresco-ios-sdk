//
//  CMISAtomPubBaseService+Protected.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 04/05/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISAtomPubBaseService.h"
#import "CMISObjectByIdUriBuilder.h"

@class CMISObjectData;

@interface CMISAtomPubBaseService (Protected)

- (void)fetchRepositoryInfoAndReturnError:(NSError * *)error;

- (NSArray *)retrieveCMISWorkspacesAndReturnError:(NSError * *)error;

/** Convenience method with all the default for the retrieval parameters */
- (CMISObjectData *)retrieveObjectInternal:(NSString *)objectId error:(NSError **)error;

- (CMISObjectData *)retrieveObjectInternal:(NSString *)objectId
           withFilter:(NSString *)filter
           andIncludeRelationShips:(CMISIncludeRelationship)includeRelationship
           andIncludePolicyIds:(BOOL)includePolicyIds
           andRenditionFilder:(NSString *)renditionFilter
           andIncludeACL:(BOOL)includeACL
           andIncludeAllowableActions:(BOOL)includeAllowableActions
           error:(NSError * *)error;

- (CMISObjectData *)retrieveObjectByPathInternal:(NSString *)path error:(NSError **)error;

- (id) retrieveFromCache:(NSString *)cacheKey error:(NSError * *)error;

@end

//
//  CMISNavigationService.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 20/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISEnums.h"

@class CMISFolder;
@class CMISObjectList;

@protocol CMISNavigationService <NSObject>

/*
 * Retrieves the children for the given object identifier.
 */
- (CMISObjectList *)retrieveChildren:(NSString *)objectId
                      orderBy:(NSString *)orderBy
                       filter:(NSString *)filter
         includeRelationShips:(CMISIncludeRelationship)includeRelationship
              renditionFilter:(NSString *)renditionFilter
      includeAllowableActions:(BOOL)includeAllowableActions
           includePathSegment:(BOOL)includePathSegment
                    skipCount:(NSNumber *)skipCount
                     maxItems:(NSNumber *)maxItems
                        error:(NSError **)error;

/**
* Retrieves the parent of a given object.
* Returns a list of CMISObjectData objects
*
* TODO: OpenCMIS returns an ObjectParentData object .... is this necessary?
*
* TODO: add all params required by cmis spec
*/
- (NSArray *)retrieveParentsForObject:(NSString *)objectId error:(NSError * *)error;

@end

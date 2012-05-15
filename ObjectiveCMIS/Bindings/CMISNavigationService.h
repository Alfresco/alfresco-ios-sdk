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

/*
 * Retrieves the children for the given object identifier.
 */
- (NSArray *)retrieveChildren:(NSString *)objectId error:(NSError **)error;

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

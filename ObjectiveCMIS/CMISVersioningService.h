//
//  CMISVersioningService.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 20/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CMISVersioningService <NSObject>

// TODO: according to spec must return all kinds of properties (see 4094 in spec), for now, we just return the objectId
- (NSString *)retrieveObjectOfLatestVersion:(NSString *)objectId error:(NSError * *)error;

/*
 * Returns the list of all Document Object in the given version series, sorted by creationDate descending (ie youngest first)
 *
 * // TODO: according to spec must return an array of all kinds of properties (see 4141 in spec), for now, we just return an array objectId
 */
- (NSArray *)retrieveAllVersions:(NSString *)objectId error:(NSError * *)error;

@end

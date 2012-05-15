//
//  CMISFileableObject.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 21/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISObject.h"

@interface CMISFileableObject : CMISObject

/**
* Returns all the parents of this object as an array of CMISFolder objects.
*
* Will be nil for root folder and non-fileable objects.
*/
- (NSArray *)retrieveParentsAndReturnError:(NSError * *)error;

@end

//
//  CMISFileableObject.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 21/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISObject.h"

@interface CMISFileableObject : CMISObject

@property (nonatomic, strong, readonly) NSArray *parents;

@end

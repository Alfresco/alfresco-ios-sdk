//
//  CMISObjectConverter.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 22/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISObject.h"
#import "CMISObjectData.h"
#import "CMISCollection.h"

@interface CMISObjectConverter : NSObject

- (id)initWithCMISBinding:(id<CMISBinding>)binding;

- (CMISObject *)convertObject:(CMISObjectData *)objectData;
- (CMISCollection *)convertObjects:(NSArray *)objects;

@end

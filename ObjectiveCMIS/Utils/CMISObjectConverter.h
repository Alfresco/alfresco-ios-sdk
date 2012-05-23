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

/**
 * Converts the given dictionary of properties, where the key is the property id and the value
 * can be a CMISPropertyData or a regular string.
 */
- (CMISProperties *)convertProperties:(NSDictionary *)properties forObjectTypeId:(NSString *)objectTypeId error:(NSError **)error;

@end

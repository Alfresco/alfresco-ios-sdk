//
//  CMISLinkRelations.h
//  ObjectiveCMIS
//
//  Created by Gi Lee on 5/13/12.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMISLinkRelations : NSObject

@property (nonatomic, strong, readonly) NSSet *linkRelationSet;

- (id)initWithLinkRelationSet:(NSSet *)linkRelationSet;

/**
 Returns the link href for the link relation. If more than one object exists for the link relation, 
 then nil is returned.  If no relation is found, nil is returned.
 */
- (NSString *)linkHrefForRel:(NSString *)rel;

/**
 Returns the link href for the link relation & link type. If more than one object exists for the link relation, 
 then nil is returned.  If no relation is found, nil is returned.
 */
- (NSString *)linkHrefForRel:(NSString *)rel type:(NSString *)type;

@end

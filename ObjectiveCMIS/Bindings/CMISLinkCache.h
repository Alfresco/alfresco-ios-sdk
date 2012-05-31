//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMISLinkRelations;
@class CMISBindingSession;


@interface CMISLinkCache : NSObject

- (id)initWithBindingSession:(CMISBindingSession *)bindingSession;

- (NSString *)linkForObjectId:(NSString *)objectId andRelation:(NSString *)rel;

- (NSString *)linkForObjectId:(NSString *)objectId andRelation:(NSString *)rel andType:(NSString *)type;

- (void)addLinks:(CMISLinkRelations *)links forObjectId:(NSString *)objectId;

- (void)removeLinksForObjectId:(NSString *)objectId;

@end
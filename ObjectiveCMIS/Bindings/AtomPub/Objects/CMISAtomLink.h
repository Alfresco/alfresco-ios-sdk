//
//  AtomLink.h
//  ObjectiveCMIS
//
//  Created by Gi Lee on 5/13/12.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMISAtomLink : NSObject

@property (nonatomic, strong) NSString *rel;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *href;

- (id)initWithRelation:(NSString *)rel type:(NSString *)type href:(NSString *)href;


@end

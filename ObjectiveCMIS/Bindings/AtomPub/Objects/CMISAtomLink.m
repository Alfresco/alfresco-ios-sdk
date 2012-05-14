//
//  AtomLink.m
//  ObjectiveCMIS
//
//  Created by Gi Lee on 5/13/12.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomLink.h"

@implementation CMISAtomLink

@synthesize rel = _rel;
@synthesize type = _type;
@synthesize href = _href;

- (id)initWithRelation:(NSString *)rel type:(NSString *)type href:(NSString *)href
{
    self = [super init];
    if (self)
    {
        self.rel = rel;
        self.type = type;
        self.href = href;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"CMISAtomLink rel=%@ type=%@ href=%@", self.rel, self.type, self.href];
}

@end

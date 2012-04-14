//
//  CMISCollection.m
//  HybridApp
//
//  Created by Cornwell Gavin on 21/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISCollection.h"

@interface CMISCollection ()
@property (nonatomic, strong, readwrite) NSArray *items;
@end

@implementation CMISCollection

@synthesize items = _items;

- (id)initWithItems:(NSArray *)items
{
    if (self = [super init])
    {
        self.items = items;
    }
    
    return self;
}

@end

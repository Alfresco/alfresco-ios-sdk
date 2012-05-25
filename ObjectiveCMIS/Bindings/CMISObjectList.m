//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISObjectList.h"
#import "CMISBinding.h"


@implementation CMISObjectList

@synthesize objects = _objects;
@synthesize hasMoreItems = _hasMoreItems;
@synthesize numItems = _numItems;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.objects = [NSArray array];
        self.numItems = 0;
        self.hasMoreItems = NO;
    }
    return self;
}

@end
//
//  CMISObjectId.m
//  HybridApp
//
//  Created by Cornwell Gavin on 21/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISObjectId.h"

@interface  CMISObjectId ()
@property (nonatomic, strong, readwrite) NSString *identifier;
@end

@implementation CMISObjectId

@synthesize identifier = _identifier;

- (id)initWithString:(NSString *)string
{
    if (self = [super init])
    {
        self.identifier = string;
    }
    
    return self;
}

@end

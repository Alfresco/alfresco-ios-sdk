//
//  CMISPropertyData.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 22/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISPropertyData.h"

@implementation CMISPropertyData

@synthesize identifier = _identifier;
@synthesize localName = _localName;
@synthesize displayName = _displayName;
@synthesize queryName = _queryName;
@synthesize values = _values;

- (id)firstValue
{
    id value = nil;
    
    if (self.values != nil && [self.values count] > 0)
    {
        value = [self.values objectAtIndex:0];
    }
    
    return value;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"identifer: %@, localName: %@, displayName: %@, queryName: %@, values: %@", 
            self.identifier, self.localName, self.displayName, self.queryName, self.values];
}

@end

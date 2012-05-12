//
//  CMISProperties.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 22/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISProperties.h"

@interface CMISProperties ()
@property (nonatomic, strong) NSMutableDictionary *internalProperties;
@end

@implementation CMISProperties

@synthesize internalProperties = _internalProperties;
@synthesize properties = _properties;
@synthesize propertyList = _propertyList;

- (void)addProperty:(CMISPropertyData *)propertyData
{
    if (self.internalProperties == nil)
    {
        self.internalProperties = [NSMutableDictionary dictionary];
    }
    
    [self.internalProperties setObject:propertyData forKey:propertyData.identifier];
}

- (NSDictionary *)properties
{
    return [NSDictionary dictionaryWithDictionary:self.internalProperties];
}

- (NSArray *)propertyList
{
    return [NSArray arrayWithArray:self.internalProperties.allValues];
}

@end

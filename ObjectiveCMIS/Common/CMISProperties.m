//
//  CMISProperties.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 22/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISProperties.h"

@interface CMISProperties ()
@property (nonatomic, strong) NSMutableDictionary *internalPropertiesByIdDict;
@property (nonatomic, strong) NSMutableDictionary *internalPropertiesByQueryNameDict;
@end

@implementation CMISProperties

@synthesize internalPropertiesByIdDict = _internalPropertiesByIdDict;
@synthesize internalPropertiesByQueryNameDict = _internalPropertiesByQueryNameDict;
@synthesize properties = _properties;
@synthesize propertyList = _propertyList;


- (void)addProperty:(CMISPropertyData *)propertyData
{
    if (self.internalPropertiesByIdDict == nil)
    {
        self.internalPropertiesByIdDict = [NSMutableDictionary dictionary];
    }
    [self.internalPropertiesByIdDict setObject:propertyData forKey:propertyData.identifier];

    if (self.internalPropertiesByQueryNameDict == nil)
    {
        self.internalPropertiesByQueryNameDict = [NSMutableDictionary dictionary];
    }
    [self.internalPropertiesByQueryNameDict setObject:propertyData forKey:propertyData.queryName];
}

- (NSDictionary *)properties
{
    return [NSDictionary dictionaryWithDictionary:self.internalPropertiesByIdDict];
}

- (NSArray *)propertyList
{
    return [NSArray arrayWithArray:self.internalPropertiesByIdDict.allValues];
}

- (CMISPropertyData *)propertyForId:(NSString *)id
{
    return [self.internalPropertiesByIdDict objectForKey:id];
}

- (CMISPropertyData *)propertyForQueryName:(NSString *)queryName
{
    return [self.internalPropertiesByQueryNameDict objectForKey:queryName];
}

- (id)propertyValueForId:(NSString *)propertyId
{
    return [[self propertyForId:propertyId] firstValue];
}

- (id)propertyValueForQueryName:(NSString *)queryName
{
    return [[self propertyForQueryName:queryName] firstValue];
}

- (NSArray *)propertyMultiValueById:(NSString *)id
{
    return [[self propertyForId:id] values];
}

- (NSArray *)propertyMultiValueByQueryName:(NSString *)queryName
{
    return [[self propertyForQueryName:queryName] values];
}


@end

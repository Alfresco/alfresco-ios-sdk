//
//  CMISPropertyData.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 22/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISPropertyData.h"

@interface CMISPropertyData ()

+ (CMISPropertyData *)createPropertyInternal:(NSString *)id value:(id)value type:(CMISPropertyType)type;

@end

@implementation CMISPropertyData

@synthesize identifier = _identifier;
@synthesize localName = _localName;
@synthesize displayName = _displayName;
@synthesize queryName = _queryName;
@synthesize values = _values;
@synthesize type = _type;

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

#pragma mark Value retrieval convenience methods
- (NSString *)propertyStringValue
{
    if (self.type == CMISPropertyTypeString)
    {
        return [self firstValue];
    }
    return nil;
}

- (NSNumber *)propertyIntegerValue
{
    if (self.type == CMISPropertyTypeInteger)
    {
        return [self firstValue];
    }
    return nil;
}

- (NSString *)propertyIdValue
{
    if (self.type == CMISPropertyTypeId)
    {
        return [self firstValue];
    }
    return nil;
}

- (NSDate *)propertyDateTimeValue
{
    if (self.type == CMISPropertyTypeDateTime)
    {
        return [self firstValue];
    }
    return nil;
}

- (NSNumber *)propertyBooleanValue
{
    if (self.type == CMISPropertyTypeBoolean)
    {
        return [self firstValue];
    }
    return nil;
}

#pragma mark Creation methods

+ (CMISPropertyData *)createPropertyInternal:(NSString *)id value:(id)value type:(CMISPropertyType)type
{
    CMISPropertyData *propertyData = [[CMISPropertyData alloc] init];
    propertyData.identifier = id;
    propertyData.values = [NSArray arrayWithObject:value];
    propertyData.type = type;
    return propertyData;
}

+ (CMISPropertyData *)createPropertyStringData:(NSString *)id value:(NSString *)value
{
    return [self createPropertyInternal:id value:value type:CMISPropertyTypeString];
}

+ (CMISPropertyData *)createPropertyIntegerData:(NSString *)id value:(NSInteger)value
{
    return [self createPropertyInternal:id value:[NSNumber numberWithInteger:value] type:CMISPropertyTypeInteger];
}

+ (CMISPropertyData *)createPropertyIdData:(NSString *)id value:(NSString *)value
{
    return [self createPropertyInternal:id value:value type:CMISPropertyTypeId];
}

+ (CMISPropertyData *)createPropertyDataTimeData:(NSString *)id value:(NSDate *)value
{
    return [self createPropertyInternal:id value:value type:CMISPropertyTypeDateTime];
}

+ (CMISPropertyData *)createPropertyBooleanData:(NSString *)id value:(BOOL)value
{
    return [self createPropertyInternal:id value:[NSNumber numberWithBool:value] type:CMISPropertyTypeBoolean];
}

@end

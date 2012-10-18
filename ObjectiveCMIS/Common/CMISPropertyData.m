/*
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
 */
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

- (NSNumber *)propertyDecimalValue
{
    if (self.type == CMISPropertyTypeDecimal)
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

+ (CMISPropertyData *)createPropertyForId:(NSString *)id withStringValue:(NSString *)value
{
    return [self createPropertyInternal:id value:value type:CMISPropertyTypeString];
}

+ (CMISPropertyData *)createPropertyForId:(NSString *)id withIntegerValue:(NSInteger)value
{
    return [self createPropertyInternal:id value:[NSNumber numberWithInteger:value] type:CMISPropertyTypeInteger];
}

+ (CMISPropertyData *)createPropertyForId:(NSString *)id withIdValue:(NSString *)value
{
    return [self createPropertyInternal:id value:value type:CMISPropertyTypeId];
}

+ (CMISPropertyData *)createPropertyForId:(NSString *)id withDateTimeValue:(NSDate *)value
{
    return [self createPropertyInternal:id value:value type:CMISPropertyTypeDateTime];
}

+ (CMISPropertyData *)createPropertyForId:(NSString *)id withBoolValue:(BOOL)value
{
    return [self createPropertyInternal:id value:[NSNumber numberWithBool:value] type:CMISPropertyTypeBoolean];
}

@end

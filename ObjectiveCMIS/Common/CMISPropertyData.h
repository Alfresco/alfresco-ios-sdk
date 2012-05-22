//
//  CMISPropertyData.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 22/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISEnums.h"

@interface CMISPropertyData : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *localName;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *queryName;

@property CMISPropertyType type;

// Returns the list of values of this property. 
// For a single value property this is a list with one entry
@property (nonatomic, strong) NSArray *values;

// Returns the first entry of the list of values.
@property (nonatomic, assign, readonly) id firstValue;

/** Convenience method for retrieving the string value. Returns nil if property is not of string type */
- (NSString *)propertyStringValue;

/** Convenience method for retrieving the integer value. Returns nil if property is not of integer type */
- (NSNumber *)propertyIntegerValue;

/** Convenience method for retrieving the id value. Returns nil if property is not of id type */
- (NSString *)propertyIdValue;

/** Convenience method for retrieving the datetime value. Returns nil if property is not of datetime type */
- (NSDate *)propertyDateTimeValue;

/** Convenience method for retrieving the boolean value. Returns nil if property is not of boolean type */
- (NSNumber *)propertyBooleanValue;

/** Creation of a string property */
+ (CMISPropertyData *)createPropertyForId:(NSString *)id withStringValue:(NSString *)value;

/** Creation of an integer property */
+ (CMISPropertyData *)createPropertyForId:(NSString *)id withIntegerValue:(NSInteger)value;

/** Creation of an id property */
+ (CMISPropertyData *)createPropertyForId:(NSString *)id withIdValue:(NSString *)value;

/** Creation of a datetime property */
+ (CMISPropertyData *)createPropertyForId:(NSString *)id withDateTimeValue:(NSDate *)value;

/** Creation of a boolean property */
+ (CMISPropertyData *)createPropertyForId:(NSString *)id withBoolValue:(BOOL)value;

@end

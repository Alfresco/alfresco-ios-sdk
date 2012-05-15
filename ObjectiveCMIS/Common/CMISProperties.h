//
//  CMISProperties.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 22/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISPropertyData.h"

@interface CMISProperties : NSObject

// Dictionary of property id -> CMISPropertyData
@property (nonatomic, strong, readonly) NSDictionary *properties;

// List of CMISPropertyData objects
@property (nonatomic, strong, readonly) NSArray *propertyList;

// adds a property
- (void)addProperty:(CMISPropertyData *)propertyData;

/**
* Returns a property by id.
* <p>
* Since repositories are not obligated to add property ids to their query
* result properties, this method might not always work as expected with
* some repositories. Use {@link #getPropertyByQueryName(String)} instead.
*/
- (CMISPropertyData *)propertyForId:(NSString *)id;

/**
* Returns a property by query name or alias.
*/
- (CMISPropertyData *)propertyForQueryName:(NSString *)queryName;

/**
* Returns a property (single) value by id.
*/
- (id)propertyValueForId:(NSString *)propertyId;

/**
* Returns a property (single) value by query name or alias.
*
* @see #getPropertyByQueryName(String)
*/
- (id)propertyValueForQueryName:(NSString *)queryName;

/**
* Returns a property multi-value by id.
*/
- (NSArray *)propertyMultiValueById:(NSString *)id;

/**
* Returns a property multi-value by query name or alias.
*/
- (NSArray *)propertyMultiValueByQueryName:(NSString *)queryName;

@end

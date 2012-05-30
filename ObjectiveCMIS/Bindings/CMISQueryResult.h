//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMISPropertyData;
@class CMISAllowableActions;
@class CMISObjectData;
@class CMISProperties;


@interface CMISQueryResult : NSObject

/**
* Returns a list of all properties (objects of type CMISPropertyData) in this query result.
*/
@property(nonatomic, strong, readonly) CMISProperties *properties;
@property(nonatomic, strong, readonly) CMISAllowableActions *allowableActions;

/**
* Initializes this query result.
*/
- (id)initWithCmisObjectData:(CMISObjectData *)cmisObjectData;

/**
* Convience method for the initializer.
*/
+ (CMISQueryResult *)queryResultUsingCmisObjectData:(CMISObjectData *)cmisObjectData;

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
- (CMISPropertyData *)properyForQueryName:(NSString *)queryName;

/**
* Returns a property (single) value by id.
*/
- (id)properyValueForId:(NSString *)propertyId;

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

// TODO: implement following methods found in openCMIS
//    /**
//     * Returns the relationships if they were requested.
//     */
//    List<Relationship> getRelationships();
//
//    /**
//     * Returns the renditions if they were requested.
//     */
//    List<Rendition> getRenditions();

@end
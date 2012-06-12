//
//  CMISObject.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 21/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISObjectData.h"
#import "CMISBinding.h"
#import "CMISObjectId.h"

@class CMISSession;

@interface CMISObject : CMISObjectId

@property (nonatomic, strong, readonly) CMISSession *session;
@property (nonatomic, strong, readonly) id<CMISBinding> binding;

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *createdBy;
@property (nonatomic, strong, readonly) NSDate *creationDate;
@property (nonatomic, strong, readonly) NSString *lastModifiedBy;
@property (nonatomic, strong, readonly) NSDate *lastModificationDate;
@property (nonatomic, strong, readonly) NSString *objectType;
@property (nonatomic, strong, readonly) NSString *changeToken;
//@property (nonatomic, strong, readonly) CMISBaseTypeId *baseTypeId;
//@property (nonatomic, strong, readonly) CMISObjectType *baseType;
//@property (nonatomic, strong, readonly) CMISObjectType *type;
@property (nonatomic, strong, readonly) CMISAllowableActions *allowableActions;
@property (nonatomic, strong, readonly) NSArray *renditions; // An array containing CMISRendition objects

@property (nonatomic, strong, readonly) CMISProperties *properties;

- (id)initWithObjectData:(CMISObjectData *)objectData withSession:(CMISSession *)session;

/**
 * Updates the properties that are provided.
 *
 * @param properties The properties to update. The key should be the property id.
 *                   The value can be an instance of CMISPropertyData, or a regular string.
 *                   If it is a string, a conversion to the CMISPropertyData will be done for you,
 *                   but keep in mind that this can trigger another remote call to the server to fetch the type info.
 *
 * @return the updated object (a repository might have created a new version of the object)
*/
- (CMISObject *)updateProperties:(NSDictionary *)properties error:(NSError **)error;

/**
 * Returns the extensions for the given level as an array of CMISExtensionElement
 */
- (NSArray *)extensionsForExtensionLevel:(CMISExtensionLevel)extensionLevel;

@end


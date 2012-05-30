//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISEnums.h"

@class CMISPropertyDefinition;


@interface CMISTypeDefinition : NSObject

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *localName;
@property (nonatomic, strong) NSString *localNameSpace;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *queryName;
@property (nonatomic, strong) NSString *description;
@property CMISBaseType baseTypeId;

@property BOOL isCreatable;
@property BOOL isFileable;
@property BOOL isQueryable;
@property BOOL isFullTextIndexed;
@property BOOL isIncludedInSupertypeQuery;
@property BOOL isControllablePolicy;
@property BOOL isControllableAcl;

// Mapping of property id <-> CMISPropertyDefinition
@property (nonatomic, strong, readonly) NSDictionary *propertyDefinitions;

- (void)addPropertyDefinition:(CMISPropertyDefinition *)propertyDefinition;
- (CMISPropertyDefinition *)propertyDefinitionForId:(NSString *)propertyId;

@end
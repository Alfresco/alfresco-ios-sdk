//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISEnums.h"


// TODO: type specific properties, see cmis spec line 527
@interface CMISPropertyDefinition : NSObject


@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *localName;
@property (nonatomic, strong) NSString *localNamespace;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *queryName;
@property (nonatomic, strong) NSString *description;
@property CMISPropertyType propertyType;
@property CMISCardinality cardinality;
@property CMISUpdatability updatability;

@property BOOL isInherited;
@property BOOL isRequired;
@property BOOL isQueryable;
@property BOOL isOrderable;
@property BOOL isOpenChoice;

@property (nonatomic, strong) NSArray *defaultValues;
@property (nonatomic, strong) NSArray *choices;

@end
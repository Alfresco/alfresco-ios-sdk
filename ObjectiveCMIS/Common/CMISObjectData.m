//
//  CMISObjectData.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 22/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISObjectData.h"
#import "CMISRenditionData.h"

@implementation CMISObjectData

@synthesize identifier = _identifier;
@synthesize baseType = _baseType;
@synthesize properties = _properties;
@synthesize linkRelations = _linkRelations;
@synthesize contentUrl = _contentUrl;
@synthesize allowableActions = _allowableActions;
@synthesize renditions = _renditions;

@end

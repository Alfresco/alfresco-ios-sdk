//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISTypeDefinition.h"
#import "CMISPropertyDefinition.h"

@interface CMISTypeDefinition ()

@property (nonatomic, strong) NSMutableDictionary *internalPropertyDefinitions;

@end


@implementation CMISTypeDefinition

@synthesize id = _id;
@synthesize localName = _localName;
@synthesize localNameSpace = _localNameSpace;
@synthesize displayName = _displayName;
@synthesize queryName = _queryName;
@synthesize description = _description;
@synthesize baseTypeId = _baseTypeId;
@synthesize isCreatable = _isCreatable;
@synthesize isFileable = _isFileable;
@synthesize isQueryable = _isQueryable;
@synthesize isFullTextIndexed = _isFullTextIndexed;
@synthesize isIncludedInSupertypeQuery = _isIncludedInSupertypeQuery;
@synthesize isControllablePolicy = _isControllablePolicy;
@synthesize isControllableAcl = _isControllableAcl;
@synthesize propertyDefinitions = _propertyDefinitions;
@synthesize internalPropertyDefinitions = _internalPropertyDefinitions;

- (NSDictionary *)propertyDefinitions
{
    return self.internalPropertyDefinitions;
}

- (void)addPropertyDefinition:(CMISPropertyDefinition *)propertyDefinition
{
    if (self.internalPropertyDefinitions == nil)
    {
        self.internalPropertyDefinitions = [[NSMutableDictionary alloc] init];
    }
    [self.internalPropertyDefinitions setObject:propertyDefinition forKey:propertyDefinition.id];
}

@end
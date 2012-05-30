//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISPropertyDefinition.h"


@implementation CMISPropertyDefinition

@synthesize id = _id;
@synthesize localName = _localName;
@synthesize localNamespace = _localNamespace;
@synthesize displayName = _displayName;
@synthesize queryName = _queryName;
@synthesize description = _description;
@synthesize propertyType = _propertyType;
@synthesize cardinality = _cardinality;
@synthesize updatability = _updatability;
@synthesize isInherited = _isInherited;
@synthesize isRequired = _isRequired;
@synthesize isQueryable = _isQueryable;
@synthesize isOrderable = _isOrderable;
@synthesize isOpenChoice = _isOpenChoice;
@synthesize defaultValues = _defaultValues;
@synthesize choices = _choices;

@end
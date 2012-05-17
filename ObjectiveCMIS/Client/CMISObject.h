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

@interface CMISObject : CMISObjectId

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

@property (nonatomic, strong, readonly) CMISProperties *properties;

- (id)initWithObjectData:(CMISObjectData *)objectData binding:(id<CMISBinding>)binding;

@end


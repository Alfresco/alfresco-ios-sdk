//
//  CMISObject.h
//  HybridApp
//
//  Created by Cornwell Gavin on 21/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISObjectId.h"
#import "CMISObjectData.h"
#import "CMISBindingProtocols.h"

@interface CMISObject : CMISObjectId

// list of CMISProperty objects
//@property (nonatomic, strong, readonly) NSArray *properties;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *createdBy;
@property (nonatomic, strong, readonly) NSDate *creationDate;
@property (nonatomic, strong, readonly) NSString *lastModifiedBy;
@property (nonatomic, strong, readonly) NSDate *lastModificationDate;
//@property (nonatomic, strong, readonly) CMISBaseTypeId *baseTypeId;
//@property (nonatomic, strong, readonly) CMISObjectType *baseType;
//@property (nonatomic, strong, readonly) CMISObjectType *type;
//@property (nonatomic, strong, readonly) NSString *changeToken;

//- (CMISProperty *) propertyWithId:(NSString *)id;

//- (id) propertyValueWithId:(NSString *)id;

@property (nonatomic, strong, readonly) id<CMISBindingDelegate> binding;


- (id)initWithObjectData:(CMISObjectData *)objectData binding:(id<CMISBindingDelegate>)binding;

@end


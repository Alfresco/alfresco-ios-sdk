//
//  ObjectiveCMISTests.h
//  ObjectiveCMISTests
//
//  Created by Cornwell Gavin on 17/03/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "CMISSessionParameters.h"

@interface ObjectiveCMISTests : SenTestCase

@property (nonatomic, strong) CMISSessionParameters *parameters;
@property (nonatomic, strong) NSString *repositoryId;
@property (nonatomic, strong) NSString *rootFolderId;

@end

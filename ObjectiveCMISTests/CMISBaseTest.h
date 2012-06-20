//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>

@class CMISFolder;
@class CMISSession;
@class CMISSessionParameters;

typedef void (^CMISTestBlock)(void);

@interface CMISBaseTest : SenTestCase

@property (nonatomic, strong) CMISSessionParameters *parameters;
@property (nonatomic, strong) CMISSession *session;
@property (nonatomic, strong) CMISFolder *rootFolder;
@property BOOL callbackCompleted;

- (void) runTest:(CMISTestBlock)testBlock;

@end
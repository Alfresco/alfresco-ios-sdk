/*
  Licensed to the Apache Software Foundation (ASF) under one
  or more contributor license agreements.  See the NOTICE file
  distributed with this work for additional information
  regarding copyright ownership.  The ASF licenses this file
  to you under the Apache License, Version 2.0 (the
  "License"); you may not use this file except in compliance
  with the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an
  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  KIND, either express or implied.  See the License for the
  specific language governing permissions and limitations
  under the License.
 */
 
#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>
#import "CMISDocument.h"

@class CMISFolder;
@class CMISSession;
@class CMISSessionParameters;

typedef void (^CMISTestBlock)(void);

@interface CMISBaseTest : SenTestCase

@property (nonatomic, strong) CMISSessionParameters *parameters;
@property (nonatomic, strong) CMISSession *session;
@property (nonatomic, strong) CMISFolder *rootFolder;
@property BOOL testCompleted;

#pragma mark Running the test

- (void) runTest:(CMISTestBlock)testBlock;
- (void) runTest:(CMISTestBlock)testBlock withExtraSessionParameters:(NSDictionary *)extraSessionParameters;

#pragma mark Configuration of cmis parameters

// Subclasses can override this. The parameter key-value pairs will be added to the
// session parameters before construction of the cmis session.
- (NSDictionary *)customCmisParameters;

#pragma mark Helper Methods

- (void)retrieveVersionedTestDocumentWithCompletionBlock:(void (^)(CMISDocument *document))completionBlock;

- (void)uploadTestFileWithCompletionBlock:(void (^)(CMISDocument *document))completionBlock;

- (void)deleteDocumentAndVerify:(CMISDocument *)document completionBlock:(void (^)(void))completionBlock;

- (void)waitForCompletion:(NSTimeInterval)timeoutSecs;

- (NSDateFormatter *)testDateFormatter;

- (NSString *)stringFromCurrentDate;
@end
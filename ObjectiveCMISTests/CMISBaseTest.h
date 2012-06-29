/*
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
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
@property BOOL callbackCompleted;

- (void) runTest:(CMISTestBlock)testBlock;
- (void) runTest:(CMISTestBlock)testBlock withExtraSessionParameters:(NSDictionary *)extraSessionParameters;

#pragma mark Helper Methods

- (CMISDocument *)retrieveVersionedTestDocument;

- (CMISDocument *)uploadTestFile;

- (void)waitForCompletion:(NSTimeInterval)timeoutSecs;

- (void)deleteDocumentAndVerify:(CMISDocument *)document;

- (NSDateFormatter *)testDateFormatter;

- (NSString *)stringFromCurrentDate;
@end
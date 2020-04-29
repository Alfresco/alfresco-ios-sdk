/*******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Mobile SDK.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AlfrescoBatchProcessor.h"
#import "AlfrescoLog.h"

// Unit of work implementation for retrieving the HTML of a web site

@interface RetrieveHomePageWithSessionUnitOfWork : AlfrescoUnitOfWork
@property (nonatomic, strong) NSURL *url;
- (instancetype)initWithURL:(NSURL *)url;
@end

@implementation RetrieveHomePageWithSessionUnitOfWork

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super initWithKey:[url absoluteString]];
    
    if (self)
    {
        self.url = url;
    }
    
    return self;
}

- (void)startWork
{
    AlfrescoLogDebug(@"Retrieving homepage for: %@", self.url);
    
    // use NSURLSession to retrieve the home page
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:self.url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error)
        {
            AlfrescoLogDebug(@"Failed to retrieve homepage for: %@", self.url);
            
            [self completeWorkWithResult:error];
        }
        else
        {
            AlfrescoLogDebug(@"Successfully retrieved homepage for: %@", self.url);
            
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self completeWorkWithResult:responseString];
        }
    }] resume];
}

@end


@interface RetrieveHomePageWithConnectionUnitOfWork : AlfrescoUnitOfWork <NSURLConnectionDataDelegate>
@property (nonatomic, strong) NSURL *url;
- (instancetype)initWithURL:(NSURL *)url;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, assign) NSInteger statusCode;
@end

@implementation RetrieveHomePageWithConnectionUnitOfWork

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super initWithKey:[url absoluteString]];
    
    if (self)
    {
        self.url = url;
    }
    
    return self;
}

- (void)startWork
{
    AlfrescoLogDebug(@"Retrieving homepage for: %@", self.url);
    
    // use NSURLConnection to retrieve the home page
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:self.url
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:60];
    
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [connection start];
}

#pragma URL delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        self.statusCode = httpResponse.statusCode;
    }
    else
    {
        self.statusCode = -1;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (nil == data)
    {
        return;
    }
    
    if (data.length == 0)
    {
        return;
    }
    
    if (self.responseData)
    {
        [self.responseData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.statusCode == 200)
    {
        AlfrescoLogDebug(@"Successfully retrieved homepage for: %@", self.url);
        
        NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
        [self completeWorkWithResult:responseString];
    }
    else
    {
        AlfrescoLogDebug(@"Failed to retrieve homepage for: %@", self.url);
        
        [self completeWorkWithResult:[NSError errorWithDomain:@"UnitTest" code:0 userInfo:nil]];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    AlfrescoLogDebug(@"Failed to retrieve homepage for: %@", self.url);
    [self completeWorkWithResult:error];
}

@end


// Unit of work implementation that sleeps the current thread twice. The key is used to represent the time to sleep in seconds.

@interface SleepingUnitOfWork : AlfrescoUnitOfWork
@end

@implementation SleepingUnitOfWork

- (void)startWork
{
    AlfrescoLogDebug(@"Sleeping for %@ seconds the first time", self.key);
    
    [NSThread sleepForTimeInterval:[self.key doubleValue]];
    
    AlfrescoLogDebug(@"Finished sleeping for %@ seconds the first time", self.key);
    
    if (self.cancelled)
    {
        [self cancelWork];
    }
    else
    {
        AlfrescoLogDebug(@"Sleeping for %@ seconds the second time", self.key);
        
        [NSThread sleepForTimeInterval:[self.key doubleValue]];
        
        AlfrescoLogDebug(@"Finished sleeping for %@ seconds the second time", self.key);
        
        [self completeWorkWithResult:@(YES)];
    }
}

@end

@interface NoResultUnitOfWork : AlfrescoUnitOfWork
@property (nonatomic, assign) BOOL completeWithNil;
// setting completeWithNil will complete the unit of work with nil, otherwise call completeWorkWithNoResult
- (instancetype)initWithSecondsDelay:(NSString *)seconds completeWithNil:(BOOL)completeWithNil;
@end

@implementation NoResultUnitOfWork

- (instancetype)initWithSecondsDelay:(NSString *)seconds completeWithNil:(BOOL)completeWithNil
{
    self = [self initWithKey:seconds];
    if (self)
    {
        self.completeWithNil = completeWithNil;
    }
    return self;
}

- (void)startWork
{
    AlfrescoLogDebug(@"Sleeping for %@ seconds", self.key);
    
    [NSThread sleepForTimeInterval:[self.key doubleValue]];
    
    AlfrescoLogDebug(@"Finished sleeping for %@ seconds", self.key);
    
    if (self.completeWithNil)
    {
        [self completeWorkWithResult:nil];
    }
    else
    {
        [self completeWorkWithNoResult];
    }
}

@end

// Tests

@interface AlfrescoBatchProcessorTest : XCTestCase

@end

@implementation AlfrescoBatchProcessorTest

- (void)testHomepageRetrievalWithConnection
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Batch processor result expectation"];
    
    AlfrescoBatchProcessor *bp = [[AlfrescoBatchProcessor alloc] initWithCompletionBlock:^(NSDictionary *results, NSDictionary *errors) {
        AlfrescoLogDebug(@"Homepage retrieval with connection batch processor completed");
        [expectation fulfill];
        
        // check results
        XCTAssertNotNil(results, @"Expected the results dictionary to be returned");
        XCTAssertTrue(results.count == 3, @"Expected there to be 3 results");
        XCTAssertTrue(errors.count == 1, @"Expected there to be 1 error");
    }];
    
    RetrieveHomePageWithConnectionUnitOfWork *google = [[RetrieveHomePageWithConnectionUnitOfWork alloc] initWithURL:[NSURL URLWithString:@"http://www.google.com"]];
    RetrieveHomePageWithConnectionUnitOfWork *apple = [[RetrieveHomePageWithConnectionUnitOfWork alloc] initWithURL:[NSURL URLWithString:@"http://www.apple.com"]];
    RetrieveHomePageWithConnectionUnitOfWork *microsoft = [[RetrieveHomePageWithConnectionUnitOfWork alloc] initWithURL:[NSURL URLWithString:@"http://www.microsoft.com"]];
    RetrieveHomePageWithConnectionUnitOfWork *localhost = [[RetrieveHomePageWithConnectionUnitOfWork alloc] initWithURL:[NSURL URLWithString:@"http://www.localhost.com"]];
    
    // add the work
    [bp addUnitOfWork:google];
    [bp addUnitOfWork:apple];
    [bp addUnitOfWork:microsoft];
    [bp addUnitOfWork:localhost];
    
    // start the processor
    [bp start];
    
    XCTAssertFalse(bp.cancelled, @"Expected the cancelled flag to be false");
    XCTAssertTrue(bp.inProgress, @"Expected the inProgress flag to be true");
    
    // wait for the future result
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testHomepageRetrievalWithSession
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Batch processor result expectation"];
    
    AlfrescoBatchProcessor *bp = [[AlfrescoBatchProcessor alloc] initWithCompletionBlock:^(NSDictionary *results, NSDictionary *errors) {
        AlfrescoLogDebug(@"Homepage retrieval with session batch processor completed");
        [expectation fulfill];
        
        // check results
        XCTAssertNotNil(results, @"Expected the results dictionary to be returned");
        XCTAssertTrue(results.count == 3, @"Expected there to be 3 results");
        XCTAssertTrue(errors.count == 1, @"Expected there to be 1 error");
    }];
    
    RetrieveHomePageWithSessionUnitOfWork *google = [[RetrieveHomePageWithSessionUnitOfWork alloc] initWithURL:[NSURL URLWithString:@"http://www.google.com"]];
    RetrieveHomePageWithSessionUnitOfWork *apple = [[RetrieveHomePageWithSessionUnitOfWork alloc] initWithURL:[NSURL URLWithString:@"http://www.apple.com"]];
    RetrieveHomePageWithSessionUnitOfWork *microsoft = [[RetrieveHomePageWithSessionUnitOfWork alloc] initWithURL:[NSURL URLWithString:@"http://www.microsoft.com"]];
    RetrieveHomePageWithSessionUnitOfWork *localhost = [[RetrieveHomePageWithSessionUnitOfWork alloc] initWithURL:[NSURL URLWithString:@"http://www.localhost.com"]];
    
    // add the work
    [bp addUnitOfWork:google];
    [bp addUnitOfWork:apple];
    [bp addUnitOfWork:microsoft];
    [bp addUnitOfWork:localhost];
    
    // start the processor
    [bp start];
    
    XCTAssertFalse(bp.cancelled, @"Expected the cancelled flag to be false");
    XCTAssertTrue(bp.inProgress, @"Expected the inProgress flag to be true");
    
    // wait for the future result
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testCancellation
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Batch processor result expectation"];
    
    AlfrescoBatchProcessor *bp = [[AlfrescoBatchProcessor alloc] initWithCompletionBlock:^(NSDictionary *results, NSDictionary *errors) {
        AlfrescoLogDebug(@"Cancellation batch processor completed");
        [expectation fulfill];
        
        // check results
        XCTAssertTrue(results.count == 0, @"Expected there to be 0 results but there were: %lu", (unsigned long)results.count);
        XCTAssertTrue(errors.count == 2, @"Expected there to be 2 errors but there were: %lu", (unsigned long)errors.count);
    }];
    
    SleepingUnitOfWork *sleepFor3Seconds = [[SleepingUnitOfWork alloc] initWithKey:@"3"];
    SleepingUnitOfWork *sleepFor5Seconds = [[SleepingUnitOfWork alloc] initWithKey:@"5"];
    
    // add the work
    [bp addUnitOfWork:sleepFor3Seconds];
    [bp addUnitOfWork:sleepFor5Seconds];
    
    // start the processor
    [bp start];
    
    XCTAssertFalse(bp.cancelled, @"Expected the cancelled flag to be false");
    XCTAssertTrue(bp.inProgress, @"Expected the inProgress flag to be true");
    
    // cancel the processor
    [bp cancel];
    
    XCTAssertTrue(bp.cancelled, @"Expected the cancelled flag to be true");
    XCTAssertFalse(bp.inProgress, @"Expected the inProgress flag to be false");
    
    // wait for the future result
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testNilCompletionBlock
{
    AlfrescoBatchProcessor *bp = [[AlfrescoBatchProcessor alloc] initWithCompletionBlock:nil];
    
    SleepingUnitOfWork *sleepFor1Second = [[SleepingUnitOfWork alloc] initWithKey:@"1"];
    
    // add the work
    [bp addUnitOfWork:sleepFor1Second];
    
    // start the processor
    [bp start];
    
    // give the processor a chance to execute the unit of work by sleeping
    [NSThread sleepForTimeInterval:5];
    
    // check it completed successfully without a completion block
    XCTAssertFalse(bp.cancelled, @"Expected the cancelled flag to be false");
    XCTAssertFalse(bp.inProgress, @"Expected the inProgress flag to be false");
}

- (void)testMaxConcurrentOption
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Batch processor result expectation"];
    
    // take a note of the time now
    NSTimeInterval startTime = [NSDate date].timeIntervalSince1970;
    
    // limit the processor to one unit of work at a time
    AlfrescoBatchProcessorOptions *options = [AlfrescoBatchProcessorOptions new];
    options.maxConcurrentUnitsOfWork = 1;
    
    AlfrescoBatchProcessor *bp = [[AlfrescoBatchProcessor alloc] initWithOptions:options completionBlock:^(NSDictionary *results, NSDictionary *errors) {
        AlfrescoLogDebug(@"Max concurrent option batch processor completed");
        [expectation fulfill];
        
        // check results
        XCTAssertTrue(results.count == 2, @"Expected there to be 2 results but there were: %lu", (unsigned long)results.count);
        XCTAssertTrue(errors.count == 0, @"Expected there to be 0 errors but there were: %lu", (unsigned long)errors.count);
        
        // check how long it took, should be more than 16 seconds
        NSTimeInterval endTime = [NSDate date].timeIntervalSince1970;
        double elapsedTime = endTime - startTime;
        XCTAssertTrue((elapsedTime > 16), @"Expected the time elapsed to be more than 16 seconds but it was: %f", elapsedTime);
        
    }];
    
    SleepingUnitOfWork *sleepFor3Seconds = [[SleepingUnitOfWork alloc] initWithKey:@"3"];
    SleepingUnitOfWork *sleepFor5Seconds = [[SleepingUnitOfWork alloc] initWithKey:@"5"];
    
    // add the work
    [bp addUnitOfWork:sleepFor3Seconds];
    [bp addUnitOfWork:sleepFor5Seconds];
    
    // start the processor
    [bp start];
    
    // wait for the future result
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testDuplicateUnitOfWork
{
    AlfrescoBatchProcessor *bp = [[AlfrescoBatchProcessor alloc] initWithCompletionBlock:nil];
    
    SleepingUnitOfWork *sleepFor1Second = [[SleepingUnitOfWork alloc] initWithKey:@"1"];
    
    // add the work
    [bp addUnitOfWork:sleepFor1Second];
    
    // add the same unit of work again
    @try
    {
        [bp addUnitOfWork:sleepFor1Second];
        
        // fail the test if we get here
        XCTFail(@"Expected an exception to be thrown when adding a duplicate unit of work");
    }
    @catch (NSException *exception)
    {
        // expecting the exception to be thrown
    }
}

- (void)testAddUnitOfWorkAfterStart
{
    AlfrescoBatchProcessor *bp = [[AlfrescoBatchProcessor alloc] initWithCompletionBlock:nil];
    
    SleepingUnitOfWork *sleepFor3Seconds = [[SleepingUnitOfWork alloc] initWithKey:@"3"];
    SleepingUnitOfWork *sleepFor5Seconds = [[SleepingUnitOfWork alloc] initWithKey:@"5"];
    
    // add the work
    [bp addUnitOfWork:sleepFor5Seconds];
    
    // start the processor
    [bp start];
    
    // add some more work
    @try
    {
        [bp addUnitOfWork:sleepFor3Seconds];
        
        // fail the test if we get here
        XCTFail(@"Expected an exception to be thrown when adding work after the processor has started");
    }
    @catch (NSException *exception)
    {
        // expecting the exception to be thrown
    }
}

- (void)testUnitOfWorkWithNoResultMethod
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Batch processor result expectation"];
    
    NSString *secondString = @"2";
    
    AlfrescoBatchProcessor *batchProcessor = [[AlfrescoBatchProcessor alloc] initWithCompletionBlock:^(NSDictionary *results, NSDictionary *errors) {
        [expectation fulfill];
        
        XCTAssertNil(errors, @"Errors dictionary should be nil");
        XCTAssertTrue(errors.count == 0, @"Errors dictionary should not contain any errors");
        XCTAssertTrue(results.count > 0, @"There should be more than 0 results");
        id firstResultObject = results[secondString];
        XCTAssertTrue([firstResultObject isKindOfClass:[AlfrescoUnitOfWorkNoResult class]], @"The result should be of class type %@", NSStringFromClass([AlfrescoUnitOfWorkNoResult class]));
    }];
    
    NoResultUnitOfWork *noResultUnitOfWork = [[NoResultUnitOfWork alloc] initWithSecondsDelay:secondString completeWithNil:NO];
    
    [batchProcessor addUnitOfWork:noResultUnitOfWork];
    
    [batchProcessor start];
    
    [self waitForExpectationsWithTimeout:30.0f handler:nil];
}

- (void)testUnitOfWorkWithNoResultNil
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Batch processor result expectation"];
    
    NSString *secondString = @"5";
    
    AlfrescoBatchProcessor *batchProcessor = [[AlfrescoBatchProcessor alloc] initWithCompletionBlock:^(NSDictionary *results, NSDictionary *errors) {
        [expectation fulfill];
        
        XCTAssertNil(errors, @"Errors dictionary should be nil");
        XCTAssertTrue(errors.count == 0, @"Errors dictionary should not contain any errors");
        XCTAssertTrue(results.count > 0, @"There should be more than 0 results");
        id firstResultObject = results[secondString];
        XCTAssertTrue([firstResultObject isKindOfClass:[AlfrescoUnitOfWorkNoResult class]], @"The result should be of class type %@", NSStringFromClass([AlfrescoUnitOfWorkNoResult class]));
    }];
    
    NoResultUnitOfWork *noResultUnitOfWork = [[NoResultUnitOfWork alloc] initWithSecondsDelay:secondString completeWithNil:YES];
    
    [batchProcessor addUnitOfWork:noResultUnitOfWork];
    
    [batchProcessor start];
    
    [self waitForExpectationsWithTimeout:30.0f handler:nil];
}

@end

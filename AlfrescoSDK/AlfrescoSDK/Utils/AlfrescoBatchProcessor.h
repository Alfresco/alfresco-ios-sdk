/*
 ******************************************************************************
 * Copyright (C) 2005-2014 Alfresco Software Limited.
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
 *****************************************************************************
 */

#import <Foundation/Foundation.h>

typedef void (^AlfrescoBatchProcessorCompletionBlock)(NSDictionary *results, NSDictionary *errors);

@interface AlfrescoUnitOfWorkNoResult : NSObject
@end

/**
 An AlfrescoUnitOfWork represents some logic that needs to be executed.
 Every unit of work must define a key that will be used to retrieve it from
 either the results or error dictionary returned via a completion block.
 
 An AlfrescoUnitOfWork subclass must implement the startWork method and once
 complete call either completeWorkWithResult: with an appropriate object i.e.
 an NSError if the execution was unsuccessful or completeWorkWithNoResult.
 */
@interface AlfrescoUnitOfWork : NSOperation

@property (nonatomic, strong, readonly) NSString *key;
@property (nonatomic, strong, readonly) id result;

/**
 Initialises with the given key.
 
 @param key The key for the unit of work.
 */
- (instancetype)initWithKey:(NSString *)key;

/**
 Called by the batch processor when it's ready to execute.
 The unit of works logic must be implemented in this method.
 */
- (void)startWork;

/**
 The subclass calls this to indicate that execution was successful but
 there was no meaningful result to store.
 */
- (void)completeWorkWithNoResult;

/**
 The subclass calls this method to indicate that execution has completed.
 
 When successful an appropriate result object should be provided, if execution
 fails an NSError object representing the error should be provided.
 */
- (void)completeWorkWithResult:(id)result;

/**
 This method is called when the batch processor is cancelled.
 
 The subclass can override this method if resources need to be cleaned
 up i.e. a connection needs to be cancelled.
 If a subclass overrides this method it MUST call [super cancelWork].
 */
- (void)cancelWork;

@end

/**
 Options for Batch Processors
 */
@interface AlfrescoBatchProcessorOptions : NSObject
@property (nonatomic, assign) NSInteger maxConcurrentUnitsOfWork;
@end

/** The AlfrescoBatchProcessor allows a set of "units of work" to be executed and 
 the caller notified, via a completion block, once they have all completed.
 The completion block returns a dictionary of results and a dictionary of errors.
 Every unit of work has a key, the result or error is stored in the appropriate 
 dictionary using the key.
 If no errors occurred during execution the errors object will be nil, if all
 units of work failed the results object will be nil.
 */
@interface AlfrescoBatchProcessor : NSObject

@property (nonatomic, assign, readonly) BOOL inProgress;
@property (nonatomic, assign, readonly) BOOL cancelled;
@property (nonatomic, strong, readonly) NSArray *queuedUnitOfWorkKeys;

/** Initialises with default options and the provided completion block.
 
 @param completionBlock The block to call when the batch processor finishes executing all units of work.
 */
- (instancetype)initWithCompletionBlock:(AlfrescoBatchProcessorCompletionBlock)completionBlock;

/** Initialises with the provided options and completion block.
 
 @param options Options for the batch processor.
 @param completionBlock The block to call when the batch processor finishes executing all units of work.
 */
- (instancetype)initWithOptions:(AlfrescoBatchProcessorOptions *)options
                completionBlock:(AlfrescoBatchProcessorCompletionBlock)completionBlock;

/**
 Adds a unit of work to the batch processor.
 If a unit of work with the same key has already been added an exception will be thrown.
 If a unit of work is added when the processor is in progress an exception will be thrown.
 
 @param work The unit of work.
 */
- (void)addUnitOfWork:(AlfrescoUnitOfWork *)work;

/**
 Starts the batch processor.
 */
- (void)start;

/**
 Cancels the batch processor. 
 All units of work are asked to cancel, once they have all reported cancellation the completion block 
 is called. If any units of work succeeded before cancel was called they will still be marked as 
 successful (present in the results dictionary), all cancelled work will be in errors dictionary.
 */
- (void)cancel;

@end


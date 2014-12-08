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

#import "AlfrescoBatchProcessor.h"
#import "AlfrescoLog.h"

@implementation AlfrescoBatchProcessorOptions
@end

#pragma mark - Batch Processor

@interface AlfrescoBatchProcessor ()
@property (nonatomic, assign, readwrite) BOOL inProgress;
@property (nonatomic, assign, readwrite) BOOL cancelled;

@property (nonatomic, copy) AlfrescoBatchProcessorCompletionBlock completionBlock;
@property (nonatomic, strong) NSMutableDictionary *results;
@property (nonatomic, strong) NSMutableDictionary *errors;
@property (nonatomic, strong) NSMutableDictionary *unitsOfWork;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSLock *mutexLock;
@end

@implementation AlfrescoBatchProcessor

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.inProgress = NO;
        self.cancelled = NO;
        self.results = [NSMutableDictionary dictionary];
        self.errors = [NSMutableDictionary dictionary];
        self.unitsOfWork = [NSMutableDictionary dictionary];
        self.mutexLock = [[NSLock alloc] init];
        
        // initialise internal queue
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.name = @"Batch Processor Queue";
    }
    
    return self;
}

- (instancetype)initWithCompletionBlock:(AlfrescoBatchProcessorCompletionBlock)completionBlock
{
    return [self initWithOptions:nil completionBlock:completionBlock];
}

- (instancetype)initWithOptions:(AlfrescoBatchProcessorOptions *)options
                completionBlock:(AlfrescoBatchProcessorCompletionBlock)completionBlock;
{
    self = [self init];
    
    if (self)
    {
        self.completionBlock = completionBlock;
        
        if (options && options.maxConcurrentUnitsOfWork)
        {
            self.queue.maxConcurrentOperationCount = options.maxConcurrentUnitsOfWork;
        }
    }
    
    return self;
}

- (NSArray *)queuedUnitOfWorkKeys
{
    return self.unitsOfWork.allKeys;
}

- (void)addUnitOfWork:(AlfrescoUnitOfWork *)work;
{
    // ensure the unit of work has a key
    assert(work.key);
    
    // ensure the unit of work is unique
    if (self.unitsOfWork[work.key])
    {
        NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                         reason:[NSString stringWithFormat:@"A unit of work with the key %@ has already been added", work.key]
                                                       userInfo:nil];
        @throw exception;
    }
    
    // units of work can not be added once the processor is in progress
    if (self.inProgress)
    {
        NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
                                                         reason:@"Units of work can not be added after start has been called"
                                                       userInfo:nil];
        @throw exception;
    }
    
    __weak AlfrescoUnitOfWork *weakUnitOfWork = work;
    work.completionBlock = ^void () {
        [self storeUnitOfWorkResult:weakUnitOfWork];
    };
    
    self.unitsOfWork[work.key] = work;
}

- (void)start
{
    self.inProgress = YES;
    
    for (AlfrescoUnitOfWork *unitOfWork in self.unitsOfWork.allValues)
    {
        [self.queue addOperation:unitOfWork];
    }
    
    AlfrescoLogDebug(@"Launched %lu units of work", (unsigned long)self.unitsOfWork.count);
}

- (void)cancel
{
    self.cancelled = YES;
    [self.queue cancelAllOperations];
    self.inProgress = NO;
    
    AlfrescoLogDebug(@"Cancelled all units of work");
}

#pragma mark Private methods

- (void)storeUnitOfWorkResult:(AlfrescoUnitOfWork *)work
{
    id result = work.result;
    NSString *key = work.key;
    
    // take out a lock so the dictionaries are only updated by one thread at a time,
    // likewise for the checking and calling of the completion block.
    [self.mutexLock lock];
    
    if ([result isKindOfClass:[NSError class]])
    {
        self.errors[key] = result;
        
        AlfrescoLogDebug(@"Stored error for key: %@", key);
    }
    else
    {
        if (!result)
        {
            result = [AlfrescoUnitOfWorkNoResult new];
        }
        
        self.results[key] = result;
        
        AlfrescoLogDebug(@"Stored result for key: %@", key);
    }
    
    // remove the unit of work from the internal dictionary
    [self.unitsOfWork removeObjectForKey:work.key];
    
    if (self.unitsOfWork.count == 0)
    {
        self.inProgress = NO;
        
        AlfrescoLogDebug(@"All units of work have completed");
        
        if (self.completionBlock != NULL)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completionBlock((self.results.count > 0) ? self.results : nil, (self.errors.count > 0) ? self.errors : nil);
            });
        }
    }
    else
    {
        AlfrescoLogDebug(@"There are %lu units of work in progress", (unsigned long)self.unitsOfWork.count);
    }
    
    // remove the lock
    [self.mutexLock unlock];
}

@end

#pragma mark - Unit Of Work

@implementation AlfrescoUnitOfWorkNoResult
@end

@interface AlfrescoUnitOfWork ()
@property (nonatomic, strong, readwrite) NSString *key;
@property (nonatomic, strong, readwrite) id result;
@property (nonatomic, assign) BOOL workCompleted;
@property (nonatomic, assign) BOOL workInProgress;
@end

@implementation AlfrescoUnitOfWork

- (instancetype)init
{
    NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
                                                     reason:@"Units of work must be created with a key"
                                                   userInfo:nil];
    @throw exception;
}

- (instancetype)initWithKey:(NSString *)key
{
    self = [super init];
    
    if (self)
    {
        self.key = key;
        self.workCompleted = NO;
        self.workInProgress = NO;
    }
    
    return self;
}

- (void)start
{
    // check for cancellation before starting
    if ([self isCancelled])
    {
        [self cancelWork];
        return;
    }
    
    // update progress state
    [self updateExecutingStateTo:YES];
    
    // start the work
    AlfrescoLogDebug(@"Work starting for key: %@", self.key);
    [self startWork];
    
    // ensure this thread stays alive until the unit of work is complete
    do
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    while (self.workCompleted == NO);
}

- (void)cancel
{
    AlfrescoLogDebug(@"Cancelling work for key: %@", self.key);
    [self cancelWork];
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isAsynchronous
{
    return YES;
}

- (BOOL)isExecuting
{
    return self.workInProgress;
}

- (BOOL)isFinished
{
    return self.workCompleted;
}

- (void)startWork
{
    @throw ([NSException exceptionWithName:@"Missing method implementation"
                                    reason:@"AlfrescoUnitOfWork subclass must override the startWork method"
                                  userInfo:nil]);
}

- (void)completeWorkWithNoResult
{
    [self completeWorkWithResult:nil];
}

- (void)completeWorkWithResult:(id)result
{
    // store the result
    self.result = result;
    
    // indicate we're done
    [self updateExecutingStateTo:NO];
    [self updateFinishedStateTo:YES];
    
    AlfrescoLogDebug(@"Work completed for key: %@", self.key);
}

- (void)cancelWork
{
    // create a cancelled error as the result
    self.result = [NSError errorWithDomain:@"Batch Processor"
                                      code:0
                                  userInfo:@{NSLocalizedDescriptionKey: @"Unit of work was cancelled."}];
    
    // update executing state, if necessary
    if (self.workInProgress)
    {
        [self updateExecutingStateTo:NO];
    }
    
    // update finished state
    [self updateFinishedStateTo:YES];
    
    AlfrescoLogDebug(@"Work cancelled for key: %@", self.key);
}

# pragma mark Private methods

- (void)updateFinishedStateTo:(BOOL)state
{
    // inform any KVO listeners before change
    [self willChangeValueForKey:@"isFinished"];
    
    self.workCompleted = state;
    
    // inform any KVO listeners after change
    [self didChangeValueForKey:@"isFinished"];
}

- (void)updateExecutingStateTo:(BOOL)state
{
    // inform any KVO listeners before change
    [self willChangeValueForKey:@"isExecuting"];
    
    self.workInProgress = state;
    
    // inform any KVO listeners after change
    [self didChangeValueForKey:@"isExecuting"];
}

@end

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

#import "CMISHttpDownloadRequest.h"
#import "CMISErrors.h"
#import "CMISLog.h"

@interface CMISHttpDownloadRequest ()

@property (nonatomic, copy) void (^progressBlock)(unsigned long long bytesDownloaded, unsigned long long bytesTotal);
@property (nonatomic, assign) unsigned long long bytesDownloaded;
@property (nonatomic, assign) BOOL cancelled;
@property (nonatomic, strong) NSError *fileCopyError;

- (id)initWithHttpMethod:(CMISHttpRequestMethod)httpRequestMethod
         completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
           progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock;

@end


@implementation CMISHttpDownloadRequest

+ (id)startRequest:(NSMutableURLRequest *)urlRequest
        httpMethod:(CMISHttpRequestMethod)httpRequestMethod
      outputStream:(NSOutputStream*)outputStream
     bytesExpected:(unsigned long long)bytesExpected
           session:(CMISBindingSession *)session
   completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
     progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    return [CMISHttpDownloadRequest startRequest:urlRequest
                                      httpMethod:httpRequestMethod
                                    outputStream:outputStream
                                   bytesExpected:bytesExpected
                                          offset:nil
                                          length:nil
                                         session:session
                                 completionBlock:completionBlock
                                   progressBlock:progressBlock];
}

+ (id)startRequest:(NSMutableURLRequest *)urlRequest
        httpMethod:(CMISHttpRequestMethod)httpRequestMethod
      outputStream:(NSOutputStream*)outputStream
     bytesExpected:(unsigned long long)bytesExpected
            offset:(NSDecimalNumber*)offset
            length:(NSDecimalNumber*)length
           session:(CMISBindingSession *)session
   completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
     progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    CMISHttpDownloadRequest *httpRequest = [[self alloc] initWithHttpMethod:httpRequestMethod
                                                            completionBlock:completionBlock
                                                              progressBlock:progressBlock];
    httpRequest.outputStream = outputStream;
    httpRequest.bytesExpected = bytesExpected;
    httpRequest.session = session;
    
    //range
    if ((offset != nil) || (length != nil)) {
        if (offset == nil) {
            offset = [NSDecimalNumber zero];
        }
        
        NSMutableString *range = [NSMutableString stringWithFormat:@"bytes=%@-",[offset stringValue]];
        
        if ((length != nil) && ([length longLongValue] >= 1)) {
            [range appendFormat:@"%llu", [offset unsignedLongLongValue] + [length unsignedLongLongValue] - 1];
        }
        
        httpRequest.additionalHeaders = [NSDictionary dictionaryWithObject:range forKey:@"Range"];
    }

    if (![httpRequest startRequest:urlRequest]) {
        httpRequest = nil;
    };
    
    return httpRequest;
}

+ (id)startRequest:(NSMutableURLRequest *)urlRequest
        httpMethod:(CMISHttpRequestMethod)httpRequestMethod
    outputFilePath:(NSString *)outputFilePath
     bytesExpected:(unsigned long long)bytesExpected
           session:(CMISBindingSession *)session
   completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
     progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock;
{
    CMISHttpDownloadRequest *httpRequest = [[self alloc] initWithHttpMethod:httpRequestMethod
                                                            completionBlock:completionBlock
                                                              progressBlock:progressBlock];
    httpRequest.outputFilePath = outputFilePath;
    httpRequest.bytesExpected = bytesExpected;
    httpRequest.session = session;
    
    if (![httpRequest startRequest:urlRequest]) {
        httpRequest = nil;
    };
    
    return httpRequest;
}

- (id)initWithHttpMethod:(CMISHttpRequestMethod)httpRequestMethod
         completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
           progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    self = [super initWithHttpMethod:httpRequestMethod
                     completionBlock:completionBlock];
    if (self) {
        _progressBlock = progressBlock;
    }
    return self;
}

- (NSURLSessionTask *)taskForRequest:(NSURLRequest *)request
{
    if (self.outputFilePath) {
        return [self.urlSession downloadTaskWithRequest:request];
    } else {
        return [super taskForRequest:request];
    }
}

#pragma mark CMISCancellableRequest method

- (void)cancel
{
    [super cancel];
    
    // clean up
    [self.outputStream close];
    self.progressBlock = nil;
}

#pragma mark Session delegate methods

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    // clean up
    [self.outputStream close];
    self.progressBlock = nil;
    
    if (self.outputFilePath) {
        // download tasks don't return the response via delegate methods so get it from the task
        self.response = (NSHTTPURLResponse *)task.response;
        
        if (self.fileCopyError) {
            error = self.fileCopyError;
        }
    }
    
    [super URLSession:session task:task didCompleteWithError:error];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    if (self.outputStream == nil) { // if there is no outputStream then store data in memory in self.data
        [super URLSession:session dataTask:dataTask didReceiveData:data];
    } else {
        const uint8_t *bytes = data.bytes;
        NSUInteger length = data.length;
        NSUInteger offset = 0;
        do {
            NSUInteger written = [self.outputStream write:&bytes[offset] maxLength:length - offset];
            if (written <= 0) {
                CMISLogError(@"Error while writing downloaded data to stream");
                [session invalidateAndCancel];
                return;
            } else {
                offset += written;
            }
        } while (offset < length);
    }
    
    // update statistics
    self.bytesDownloaded += data.length;
    
    // pass progress to progressBlock, on the original thread
    if (self.originalThread) {
        [self performSelector:@selector(executeProgressBlock:) onThread:self.originalThread withObject:@[@(self.bytesDownloaded), @(self.bytesExpected)] waitUntilDone:NO];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    // update statistics
    if (self.bytesExpected == 0 && self.sessionTask.countOfBytesExpectedToReceive != NSURLSessionTransferSizeUnknown) {
        self.bytesExpected = self.sessionTask.countOfBytesExpectedToReceive;
    }
    
    self.bytesDownloaded = 0;
    
    // set up output stream if available
    if (self.outputStream) { // otherwise store data in memory in self.data
        // create file for downloaded content
        BOOL isStreamReady = self.outputStream.streamStatus == NSStreamStatusOpen;
        if (!isStreamReady) {
            [self.outputStream open];
            isStreamReady = self.outputStream.streamStatus == NSStreamStatusOpen;
        }
        
        if (isStreamReady) {
            [super URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
        } else {
            [session invalidateAndCancel];
            
            if (self.completionBlock)
            {
                NSError *cmisError = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeStorage
                                                     detailedDescription:@"Could not open output stream"];
                
                // call the completion block on the original thread
                if (self.originalThread) {
                    [self performSelector:@selector(executeCompletionBlockError:) onThread:self.originalThread withObject:cmisError waitUntilDone:NO];
                }
            }
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // TODO: Add support for resuming download tasks
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    // create URL representation of destination
    NSURL *destinationURL = [NSURL fileURLWithPath:self.outputFilePath];

    // remove the current file, if it exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:destinationURL error:nil];
    
    // copy the temporary file to the requested file path
    if ([fileManager copyItemAtURL:location toURL:destinationURL error:nil]) {
        CMISLogDebug(@"Copied downloaded file from %@ to %@", location, self.outputFilePath);
    } else {
        self.fileCopyError = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeStorage
                                             detailedDescription:[NSString stringWithFormat:@"Could not copy temporary file to %@", self.outputFilePath]];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    // pass progress to progressBlock, on the main thread
    if (self.progressBlock) {
        unsigned long long totalBytesExpected = totalBytesExpectedToWrite;
        
        if (totalBytesExpected == NSURLSessionTransferSizeUnknown && self.bytesExpected != 0) {
            totalBytesExpected = self.bytesExpected;
        }
        // pass progress to progressBlock, on the original thread
        if (self.originalThread) {
            [self performSelector:@selector(executeProgressBlock:) onThread:self.originalThread withObject:@[@(totalBytesWritten), @(totalBytesExpected)] waitUntilDone:NO];
        }
    }
}

- (void)executeProgressBlock:(NSArray*)valueArray {
    if (self.progressBlock) {
        self.progressBlock([valueArray[0] unsignedLongLongValue], [valueArray[1] unsignedLongLongValue]);
    }
}

@end

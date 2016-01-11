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

/*
 The base64 Encoding part of this class is based on the PostController.m class
 of the sample app 'SimpleURLConnections' provided by Apple.
 http://developer.apple.com/library/ios/#samplecode/SimpleURLConnections/Introduction/Intro.html
*/

#import "CMISHttpUploadRequest.h"
#import "CMISBase64Encoder.h"
#import "CMISAtomEntryWriter.h"
#import "CMISLog.h"
#import "CMISErrors.h"

/**
 this is the buffer size for the input/output stream pair containing the base64 encoded data
 */
const NSUInteger kFullBufferSize = 32768;
/**
 this is the buffer size for the raw data. It must be an integer multiple of 3. Base64 encoding uses
 4 bytes for each 3 bytes of raw data. Therefore, the amount of raw data we take is
 kFullBufferSize/4 * 3.
 */
const NSUInteger kRawBufferSize = 24576;

/**
 A category that extends the NSStream class in order to pair an inputstream with an outputstream.
 The input stream will be used by NSURLSession via the HTTPBodyStream property of the URL request.
 The paired output stream will buffer base64 encoded as well as XML data.
 
 NOTE: the original sample code also provides a method for backward compatibility w.r.t  iOS versions below 5.0
 However, since the CMIS library is only to be used with iOS version 5.1 and higher, this code is obsolete and has
 been omitted here.
 */

@interface NSStream (StreamPair)
+ (void)createBoundInputStream:(NSInputStream **)inputStreamPtr
                  outputStream:(NSOutputStream **)outputStreamPtr;
@end

@implementation NSStream (StreamPair)
+ (void)createBoundInputStream:(NSInputStream **)inputStreamPtr
                  outputStream:(NSOutputStream **)outputStreamPtr
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    assert((inputStreamPtr != NULL) || (outputStreamPtr != NULL));
    
    readStream = NULL;
    writeStream = NULL;
    CFStreamCreateBoundPair(NULL,
                            ((inputStreamPtr != nil) ? &readStream : NULL),
                            ((outputStreamPtr != nil) ? &writeStream : NULL),
                            (CFIndex)kFullBufferSize);
    
    if (inputStreamPtr != NULL) {
        *inputStreamPtr  = CFBridgingRelease(readStream);
    }
    if (outputStreamPtr != NULL) {
        *outputStreamPtr = CFBridgingRelease(writeStream);
    }
}
@end


@interface CMISHttpUploadRequest ()

@property (nonatomic, assign) unsigned long long bytesUploaded;
@property (nonatomic, copy) void (^progressBlock)(unsigned long long bytesUploaded, unsigned long long bytesTotal);
@property (nonatomic, assign) BOOL useCombinedInputStream;
@property (nonatomic, assign) BOOL base64Encoding;
@property (nonatomic, assign) BOOL transferCompleted;
@property (nonatomic, strong) NSInputStream *combinedInputStream;
@property (nonatomic, strong) NSOutputStream *encoderStream;
@property (nonatomic, strong) NSData *streamStartData;
@property (nonatomic, strong) NSData *streamEndData;
@property (nonatomic, assign) unsigned long long encodedLength;
@property (nonatomic, strong) NSData *dataBuffer;
@property (nonatomic, assign, readwrite) size_t bufferOffset;
@property (nonatomic, assign, readwrite) size_t bufferLimit;

@end


@implementation CMISHttpUploadRequest

+ (id)startRequest:(NSMutableURLRequest *)urlRequest
        httpMethod:(CMISHttpRequestMethod)httpRequestMethod
       inputStream:(NSInputStream*)inputStream
           headers:(NSDictionary*)additionalHeaders
     bytesExpected:(unsigned long long)bytesExpected
           session:(CMISBindingSession *)session
   completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
     progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock
{
    CMISHttpUploadRequest *httpRequest = [[self alloc] initWithHttpMethod:httpRequestMethod
                                                          completionBlock:completionBlock
                                                            progressBlock:progressBlock];
    httpRequest.inputStream = inputStream;
    httpRequest.additionalHeaders = additionalHeaders;
    httpRequest.bytesExpected = bytesExpected;
    httpRequest.session = session;
    httpRequest.useCombinedInputStream = NO;
    httpRequest.combinedInputStream = nil;
    httpRequest.encoderStream = nil;
    
    if (![httpRequest startRequest:urlRequest]) {
        httpRequest = nil;
    }
    
    return httpRequest;
}

+ (id)startRequest:(NSMutableURLRequest *)urlRequest
        httpMethod:(CMISHttpRequestMethod)httpRequestMethod
       inputStream:(NSInputStream *)inputStream
           headers:(NSDictionary *)additionalHeaders
     bytesExpected:(unsigned long long)bytesExpected
           session:(CMISBindingSession *)session
         startData:(NSData *)startData
           endData:(NSData *)endData
 useBase64Encoding:(BOOL)useBase64Encoding
   completionBlock:(void (^)(CMISHttpResponse *, NSError *))completionBlock
     progressBlock:(void (^)(unsigned long long, unsigned long long))progressBlock
{
    CMISHttpUploadRequest *httpRequest = [[self alloc] initWithHttpMethod:httpRequestMethod
                                                          completionBlock:completionBlock
                                                            progressBlock:progressBlock];
    
    httpRequest.inputStream = inputStream;
    httpRequest.streamStartData = startData;
    httpRequest.streamEndData = endData;
    httpRequest.additionalHeaders = additionalHeaders;
    httpRequest.bytesExpected = bytesExpected;
    httpRequest.useCombinedInputStream = YES;
    httpRequest.base64Encoding = useBase64Encoding;
    httpRequest.session = session;
    
    [httpRequest prepareStreams];
    if (![httpRequest startRequest:urlRequest]) {
        httpRequest = nil;
    }
    
    return httpRequest;
}


- (id)initWithHttpMethod:(CMISHttpRequestMethod)httpRequestMethod
         completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
           progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock
{
    self = [super initWithHttpMethod:httpRequestMethod
                     completionBlock:completionBlock];
    if (self) {
        _progressBlock = progressBlock;
        _transferCompleted = NO;
    }
    return self;
}

/**
 if we are using on-the-go base64 encoding, we will use the combinedInputStream in URL connections/request.
 In this case a little extra work is required: i.e. we need to provide the length of the encoded data stream (including
 the XML data).
 */
- (BOOL)startRequest:(NSMutableURLRequest*)urlRequest
{
    if (self.useCombinedInputStream && self.combinedInputStream && self.base64Encoding) {
        NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:self.additionalHeaders];
        [headers setValue:[NSString stringWithFormat:@"%llu", self.encodedLength] forKey:@"Content-Length"];
        self.additionalHeaders = [NSDictionary dictionaryWithDictionary:headers];
    }

    BOOL startSuccess = [super startRequest:urlRequest];
    
    if (self.useCombinedInputStream) {
        [self.encoderStream open];
    }

    return startSuccess;
}

- (NSURLSessionTask *)taskForRequest:(NSURLRequest *)request
{
    return [self.urlSession uploadTaskWithStreamedRequest:request];
}

#pragma mark CMISCancellableRequest method

- (void)cancel
{
    if (self.transferCompleted) {
        return;
    }
    self.progressBlock = nil;
    
    [super cancel];
    if (self.useCombinedInputStream) {
        [self stopSendWithStatus:@"connection has been cancelled."];
    }
}

#pragma mark Session delegate methods

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream *))completionHandler
{
    if (self.combinedInputStream) {
        completionHandler(self.combinedInputStream);
    } else {
        completionHandler(self.inputStream);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [super URLSession:session task:task didCompleteWithError:error];
    
    if (self.useCombinedInputStream) {
        if (error) {
            [self stopSendWithStatus:@"connection is being terminated with error."];
        } else {
            [self stopSendWithStatus:@"Connection finished as expected."];
        }
    }
    
    self.progressBlock = nil;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    self.bytesUploaded = 0;
    
    [super URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    if (self.progressBlock) {
        if (self.useCombinedInputStream && self.base64Encoding) {
            // Show the actual transmitted raw data size to the user, not the base64 encoded size
            totalBytesSent = [CMISHttpUploadRequest rawEncodedLength:totalBytesSent];
            if (totalBytesSent > totalBytesExpectedToSend) {
                totalBytesSent = totalBytesExpectedToSend;
            }
        }
        
        if (self.bytesExpected == 0) {
            if (totalBytesSent >= totalBytesExpectedToSend) {
                self.transferCompleted = YES;
            }
            // pass progress to progressBlock, on the original thread
            if (self.originalThread) {
                [self performSelector:@selector(executeProgressBlock:) onThread:self.originalThread withObject:@[@(totalBytesSent), @(totalBytesExpectedToSend)] waitUntilDone:NO];
            }
        } else {
            if (totalBytesSent >= self.bytesExpected) {
                self.transferCompleted = YES;
            }
            // pass progress to progressBlock, on the original thread
            if (self.originalThread) {
                [self performSelector:@selector(executeProgressBlock:) onThread:self.originalThread withObject:@[@(totalBytesSent), @(self.bytesExpected)] waitUntilDone:NO];
            }
        }
    }
}

#pragma mark NSStreamDelegate method

/**
 For encoding base64 data - this is the meat of this class.
 The action is in the case where the eventCode == NSStreamEventHasSpaceAvailable
 
 Note 1:
 The output stream (encoderStream) is paired with the encoded input stream (combinedInputStream) which is the one
 the active URL connection uses to read from. Thereby any data made available to the outputstream will be available to this input stream as well.
 Any action on the output stream (like close) will also affect this combinedInputStream.
 
 Note 2:
 since we are encoding "on the fly" we are dealing with 2 different buffer sizes. The encoded buffer size kFullBufferSize, and the
 buffer size of the raw/non-encoded data kRawBufferSize.
 
 Note 3:
 the reading from the source input stream, as well as the writing to the encoderStream is regulated via 2 variables: bufferLimit and bufferOffset
 bufferLimit is the size of the XML data or the No of bytes read in from the raw data set (inputstream)
 At each readIn, the bufferOffset will be reset to 0 to indicate a free buffer to write to.
 When the data are finally written to the output stream, both bufferLimit and bufferOffset should be having the same value (unless we attempt to
 write more bytes than are available in the buffer).
 
 Once we reach the end of the raw data set, both bufferLimit and bufferOffset are set to 0. This indicates that the outputStream (and its paired
 input stream) can be closed.
 
 (Final Note:The Apple source code discourages removing the stream from the runloop in this method as it can cause random crashes.)
 */
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode){
        case NSStreamEventOpenCompleted:{
#if TARGET_OS_IPHONE
#ifndef __IPHONE_8_0
            // this workaround breaks POST requests on MacOS targets and iOS 8
            if (self.combinedInputStream.streamStatus != NSStreamStatusOpen) {
                [self.combinedInputStream open]; // this seems to work around the 'Stream ... is sending an event before being opened' Apple bug
            }
#endif
#endif
        }
            break;

        case NSStreamEventHasBytesAvailable: {
        }
            break;

        case NSStreamEventHasSpaceAvailable: {
            if (self.combinedInputStream) {
                NSStreamStatus inputStatus = self.combinedInputStream.streamStatus;
                if (inputStatus == NSStreamStatusClosed) {
                    CMISLogTrace(@"combinedInputStream %@ is closed", self.combinedInputStream);
                } else if (inputStatus == NSStreamStatusAtEnd){
                    CMISLogTrace(@"combinedInputStream %@ has reached the end", self.combinedInputStream);
                } else if (inputStatus == NSStreamStatusError){
                    CMISLogTrace(@"combinedInputStream %@ input stream error: %@", self.combinedInputStream, self.combinedInputStream.streamError);
                    [self stopSendWithStatus:@"Network read error"];
                }
            }
            
            if (self.bufferOffset == self.bufferLimit) {
                if (self.streamStartData != nil) {
                    self.streamStartData = nil;
                    self.bufferOffset = 0;
                    self.bufferLimit = 0;
                }
                if (self.inputStream != nil) {
                    NSInteger rawBytesRead;
                    uint8_t rawBuffer[kRawBufferSize];
                    rawBytesRead = [self.inputStream read:rawBuffer maxLength:kRawBufferSize];
                    if (-1 == rawBytesRead) {
                        [self stopSendWithStatus:@"Error while reading from source input stream"];
                    } else if (0 != rawBytesRead) {
                        
                        NSData *encodedBuffer;
                        if (self.base64Encoding) {
                            encodedBuffer = [CMISBase64Encoder dataByEncodingText:[NSData dataWithBytes:rawBuffer length:rawBytesRead]];
                        } else {
                            encodedBuffer = [NSData dataWithBytes:rawBuffer length:rawBytesRead];
                        }
                        self.dataBuffer = [NSData dataWithData:encodedBuffer];
                        self.bufferOffset = 0;
                        self.bufferLimit = encodedBuffer.length;
                    } else {
                        [self.inputStream close];
                        self.inputStream = nil;
                        self.bufferOffset = 0;
                        self.bufferLimit = self.streamEndData.length;
                        self.dataBuffer = [NSData dataWithData:self.streamEndData];
                        self.streamEndData = nil;
                    }
                    if ((self.bufferLimit == self.bufferOffset) && self.encoderStream != nil) {
                        self.encoderStream.delegate = nil;
                        [self.encoderStream close];
                    }
                } else if (self.streamEndData != nil) {
                    self.bufferOffset = 0;
                    self.bufferLimit = self.streamEndData.length;
                    self.dataBuffer = [NSData dataWithData:self.streamEndData];
                    self.streamEndData = nil;
                }
                
                if ((self.bufferOffset == self.bufferLimit) && (self.encoderStream != nil)) {
                    self.encoderStream.delegate = nil;
                    [self.encoderStream close];
                }
                
            }
            if (self.bufferOffset != self.bufferLimit) {
                NSUInteger length = self.dataBuffer.length;
                uint8_t buffer[length];
                [self.dataBuffer getBytes:buffer length:length];
                NSInteger bytesWritten;
                bytesWritten = [self.encoderStream write:&buffer[self.bufferOffset] maxLength:self.bufferLimit - self.bufferOffset];
                if (bytesWritten <= 0) {
                    [self stopSendWithStatus:@"Network write error"];
                    NSError *cmisError = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeConnection detailedDescription:@"Network write error"];
                    [self URLSession:nil task:nil didCompleteWithError:cmisError];
                } else {
                    self.bufferOffset += bytesWritten;
                }
            }
            
        }
            break;

        case NSStreamEventErrorOccurred: {
            [self stopSendWithStatus:@"Stream open error"];
        }
            break;

        case NSStreamEventEndEncountered: {
        }
            break;

        default:
            break;
    }
}


#pragma mark Private methods

- (void)prepareStreams
{
    self.bufferOffset = 0;
    
    self.bufferLimit = self.streamStartData.length;
    self.dataBuffer = [NSData dataWithData:self.streamStartData];
    
    unsigned long long bytesExpected = self.bytesExpected;
    
    if (self.base64Encoding) {
        // if base64 encoding is being used we need to adjust the bytesExpected
        bytesExpected = [CMISHttpUploadRequest base64EncodedLength:self.bytesExpected];
    }
    
    unsigned long long encodedLength = bytesExpected;
    encodedLength += self.streamStartData.length;
    encodedLength += self.streamEndData.length;
    
    // update the originally provided expected bytes with encoded length
    self.bytesExpected = encodedLength;
    self.encodedLength = self.bytesExpected;
    
    if (self.inputStream.streamStatus != NSStreamStatusOpen) {
        [self.inputStream open];
    }
    
    NSInputStream *requestInputStream;
    NSOutputStream *outputStream;
    [NSStream createBoundInputStream:&requestInputStream outputStream:&outputStream];
    assert(requestInputStream != nil);
    assert(outputStream != nil);
    self.combinedInputStream = requestInputStream;
    self.encoderStream = outputStream;
    self.encoderStream.delegate = self;
    [self.encoderStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.encoderStream open];
}


+ (unsigned long long)base64EncodedLength:(unsigned long long)contentSize
{
    if (0 == contentSize) {
        return 0;
    }
    
    unsigned long long adjustedThirdPartOfSize = (contentSize / 3) + ( (0 == contentSize % 3 ) ? 0 : 1 );
    return 4 * adjustedThirdPartOfSize;
}

+ (unsigned long long)rawEncodedLength:(unsigned long long)base64EncodedSize
{
    if (0 == base64EncodedSize) {
        return 0;
    }
    
    unsigned long long adjustedFourthPartOfSize = (base64EncodedSize / 4) + ( (0 == base64EncodedSize % 4 ) ? 0 : 1 );
    return 3 * adjustedFourthPartOfSize;
}

- (void)stopSendWithStatus:(NSString *)statusString
{
    if (nil != statusString) {
        CMISLogTrace(@"Upload request terminated: Message is %@", statusString);
    }
    self.bufferOffset = 0;
    self.bufferLimit  = 0;
    self.dataBuffer = nil;
    if (self.urlSession != nil) {
        [self.urlSession invalidateAndCancel];
        self.urlSession = nil;
    }
    if (self.encoderStream != nil) {
        self.encoderStream.delegate = nil;
        [self.encoderStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.encoderStream close];
        self.encoderStream = nil;
    }
    self.combinedInputStream = nil;
    if(self.inputStream != nil){
        [self.inputStream close];
        self.inputStream = nil;
    }
    self.streamEndData = nil;
    self.streamStartData = nil;
}

- (void)executeProgressBlock:(NSArray*)valueArray {
    if (self.progressBlock) {
        self.progressBlock([valueArray[0] unsignedLongLongValue], [valueArray[1] unsignedLongLongValue]);
    }
}

@end

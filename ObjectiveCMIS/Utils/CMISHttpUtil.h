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
#import "CMISBindingSession.h"

typedef enum {
    HTTP_GET,
    HTTP_POST,
    HTTP_PUT,
    HTTP_DELETE
} CMISHttpRequestMethod;

@interface HTTPResponse : NSObject

@property NSInteger statusCode;
@property (nonatomic, strong) NSString *statusCodeMessage;
@property (nonatomic, strong) NSData *data;

+ (HTTPResponse *)responseUsingURLHTTPResponse:(NSHTTPURLResponse *)HTTPURLResponse andData:(NSData *)data;

@end

@interface HttpUtil : NSObject

// Synchronous calls

+ (HTTPResponse *)invokeSynchronous:(NSURL *)url withHttpMethod:(CMISHttpRequestMethod)httpRequestMethod
                        withSession:(CMISBindingSession *)session
                               body:(NSData *)body
                            headers:(NSDictionary *)additionalHeaders
                              error:(NSError **)outError;

+ (HTTPResponse *)invokeSynchronous:(NSURL *)url withHttpMethod:(CMISHttpRequestMethod)httpRequestMethod
                        withSession:(CMISBindingSession *)session
                         bodyStream:(NSInputStream *)bodyStream
                            headers:(NSDictionary *)additionalHeaders
                              error:(NSError **)outError;

+ (HTTPResponse *)invokeGETSynchronous:(NSURL *)url
                           withSession:(CMISBindingSession *)session
                                 error:(NSError **)outError;

+ (HTTPResponse *)invokePOSTSynchronous:(NSURL *)url
                            withSession:(CMISBindingSession *)session
                                   body:(NSData *)body
                                  error:(NSError **)outError;

+ (HTTPResponse *)invokePOSTSynchronous:(NSURL *)url
                            withSession:(CMISBindingSession *)session
                                   body:(NSData *)body
                                headers:(NSDictionary *)additionalHeaders
                                  error:(NSError **)outError;

+ (HTTPResponse *)invokePOSTSynchronous:(NSURL *)url
                            withSession:(CMISBindingSession *)session
                             bodyStream:(NSInputStream *)bodyStream
                                headers:(NSDictionary *)additionalHeaders
                                  error:(NSError **)outError;

+ (HTTPResponse *)invokeDELETESynchronous:(NSURL *)url
                              withSession:(CMISBindingSession *)session
                                    error:(NSError **)outError;

+ (HTTPResponse *)invokePUTSynchronous:(NSURL *)url
                           withSession:(CMISBindingSession *)session
                            bodyStream:(NSInputStream *)bodyStream
                               headers:(NSDictionary *)additionalHeaders
                                 error:(NSError **)outError;

+ (HTTPResponse *)invokePUTSynchronous:(NSURL *)url
                           withSession:(CMISBindingSession *)session
                                  body:(NSData *)body
                               headers:(NSDictionary *)additionalHeaders
                                 error:(NSError **)outError;

// Async calls

+ (void)invokeGETAsynchronous:(NSURL *)url
                  withSession:(CMISBindingSession *)session
                 withDelegate:(id<NSURLConnectionDataDelegate>)delegate;

+ (void)invokePOSTAsynchronous:(NSURL *)url
                   withSession:(CMISBindingSession *)session
                          body:(NSData *)body
                  withDelegate:(id<NSURLConnectionDataDelegate>)delegate;

+ (void)invokePOSTAsynchronous:(NSURL *)url
                   withSession:(CMISBindingSession *)session
                          body:(NSData *)body
                       headers:(NSDictionary *)additionalHeaders
                  withDelegate:(id<NSURLConnectionDataDelegate>)delegate;

+ (void)invokePOSTAsynchronous:(NSURL *)url
                   withSession:(CMISBindingSession *)session
                    bodyStream:(NSInputStream *)bodyStream
                       headers:(NSDictionary *)additionalHeaders
                  withDelegate:(id<NSURLConnectionDataDelegate>)delegate;

+ (void)invokePUTAsynchronous:(NSURL *)url
                   withSession:(CMISBindingSession *)session
                    bodyStream:(NSInputStream *)bodyStream
                       headers:(NSDictionary *)additionalHeaders
                  withDelegate:(id<NSURLConnectionDataDelegate>)delegate;


@end
